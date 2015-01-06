require "rest-client"

module Komerci
  class Transaction
    class InvalidTransaction < StandardError; end

    ALLOWED_TRANSACTIONS = {
      :a_vista => "04",
      :parcelado_emissor => "06",
      :parcelado_estabelecimento => "08",
      :pre_autorizacao => "73"
    }

    attr_accessor :total, :filiation_number, :order_number, :card_number, :card_code, :card_year, :card_month, :card_owner, :auto_confirm
    attr_reader :transaction, :installments

    def transaction=(value)
      raise InvalidTransaction, value unless ALLOWED_TRANSACTIONS.include?(value)
      @transaction = value
      @installments = 0    if @transaction == :a_vista
      @auto_confirm = true if @transaction == :pre_autorizacao
    end

    def installments=(value)
      value = 0 if transaction == :a_vista
      @installments = value
    end

    def send
      uri = "https://ecommerce.redecard.com.br/pos_virtual/wskomerci/cap.asmx/GetAuthorized"
      # uri = URI(uri)
      params = {
        :Total => "%.2f" % total,
        :Transacao => ALLOWED_TRANSACTIONS[transaction],
        :Parcelas => "%02d" % installments,
        :Filiacao => filiation_number,
        :NumPedido => order_number,
        :Nrcartao => card_number,
        :CVC2 => card_code,
        :Mes => card_month,
        :Ano => card_year,
        :Portador => card_owner,

        :IATA => "",
        :Distribuidor => "",
        :Concentrador => "",
        :TaxaEmbarque => "",
        :Entrada => "",
        :Pax1 => "",
        :Pax2 => "",
        :Pax3 => "",
        :Pax4 => "",
        :Numdoc1 => "",
        :Numdoc2 => "",
        :Numdoc3 => "",
        :Numdoc4 => "",
        :ConfTxn => (auto_confirm == true ? "S" : ""),
        :AddData => ""
      }

      response = RestClient.post(uri, params)
      Authorization.from_xml(response)
    end
  end

  class PreAuthorization < Transaction
    def transaction=(value)
      raise InvalidTransaction, value unless value == :pre_autorizacao
    end

    def transaction
      :pre_autorizacao
    end

    def installments=(value)
      raise InvalidTransaction, value unless value == ""
    end

    def installments
      ""
    end

    def auto_confirm=(value)
      raise InvalidTransaction, value unless value == true
    end

    def auto_confirm
      true
    end
  end  
end
