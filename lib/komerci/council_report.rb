require "rest-client"

module Komerci
  class CouncilReport

    attr_accessor :filiation_number, :user, :password, :start_date, :end_date, :transaction_type, :transaction_status, :avs_code
    attr_reader :response_xml

    def send
      uri = "https://ecommerce.redecard.com.br/pos_virtual/wskomerci/cap.asmx/CouncilReport"
      params = {
        :Filiacao => filiation_number,
        :Data_Inicial => formatar_data(start_date),
        :Data_Final => formatar_data(end_date),
        :Tipo_Trx => transaction_type,
        :Status_Trx => transaction_status,
        :Servico_AVS => avs_code,
        
        :Distribuidor => "",
        :Programa => ""
      }

      RestClient.proxy = ENV["KOMERCI_PROXY_URL"] if ENV["KOMERCI_PROXY_URL"]
      response = RestClient.post(uri, params)
      @response_xml = response.to_str
      # TODO: classe para dados de retorno
      #Report.from_xml(response)
    end

    private
    def formatar_data data
      data.strftime "%Y%m%d" if data.present?
    end
  end

end
