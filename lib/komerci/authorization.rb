require "cgi"
require "nokogiri"

module Komerci
  class Authorization
    attr_accessor :code, :code_confirm, :order_number, :number, :receipt_number, :authentication_number, :sequential_number, :country_code
    attr_reader :message, :message_confirm, :date, :response_xml

    def date=(value)
      @date = Date.parse(value) unless value.blank?
    end

    def message=(value)
      #value = CGI.unescape(value) unless value.blank?
      @message = value
    end

    def message_confirm=(value)
      #value = CGI.unescape(value) unless value.blank?
      @message_confirm = value
    end

    def self.from_xml(string)
      @response_xml = string
      puts string
      
      xml = Nokogiri::XML(string)
      new.tap do |a|
        a.code                  = xml_text(xml, "CODRET")
        a.message               = xml_text(xml, "MSGRET")
        a.order_number          = xml_text(xml, "NUMPEDIDO")
        a.date                  = xml_text(xml, "DATA")
        a.number                = xml_text(xml, "NUMAUTOR")
        a.receipt_number        = xml_text(xml, "NUMCV")
        a.authentication_number = xml_text(xml, "NUMAUTENT")
        a.sequential_number     = xml_text(xml, "NUMSQN")
        a.country_code          = xml_text(xml, "ORIGEM_BIN")
        a.code_confirm          = xml_text(xml, "CONFCODRET")
        a.message_confirm       = xml_text(xml, "CONFMSGRET")
      end
    end

    private
    def self.xml_text root, node_name
      root.at(node_name).text unless root.nil? or root.at(node_name).nil?
    end
  end
end
