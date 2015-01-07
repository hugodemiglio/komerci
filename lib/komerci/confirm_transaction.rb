require "rest-client"

module Komerci
  class ConfirmTransaction

    attr_accessor :date, :sequence_number, :authorization, :confirmation, :total, :filiation_number, :order_number
    attr_reader :original_transaction, :installments

    def original_transaction=(value)
      raise Transaction::InvalidTransaction, value unless Transaction::ALLOWED_TRANSACTIONS.include?(value)
      @transaction = value
      @installments = 0    if @transaction == :a_vista
      @auto_confirm = true if @transaction == :pre_autorizacao
    end

    def installments=(value)
      value = 0 if transaction == :a_vista
      @installments = value
    end

    def send
      uri = "https://ecommerce.redecard.com.br/pos_virtual/wskomerci/cap.asmx/ConfirmTxn"
      # uri = URI(uri)
      params = {
        :Data => date,
        :NumSqn => sequence_number,
        :NumCV    => confirmation,
        :NumAutor => authorization,
        :Parcelas => "%02d" % installments,
        :TransOrig => ALLOWED_TRANSACTIONS[original_transaction],
        :Total => "%.2f" % total,
        :Filiacao => filiation_number,
        :NumPedido => order_number,

        :Distribuidor => "",
        :Pax1 => "",
        :Pax2 => "",
        :Pax3 => "",
        :Pax4 => "",
        :Numdoc1 => "",
        :Numdoc2 => "",
        :Numdoc3 => "",
        :Numdoc4 => "",
        :AddData => ""
      }

      RestClient.proxy = ENV["KOMERCI_PROXY_URL"] if ENV["KOMERCI_PROXY_URL"]
      response = RestClient.post(uri, params)
      Authorization.from_xml(response)
    end
  end

end
