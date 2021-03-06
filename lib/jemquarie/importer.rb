module Jemquarie

  class Importer < Base

    include Parser::CashTransactions

    def cash_transactions(date_from = (Date.today - 1.day), date_to = Date.today, account_number = '', include_closed = 'Y')
      if account_number.blank? && ((date_to - date_from).days > 2.days) # if no account specified, ESI api doesn't allow to ask more than 2 days of transactions
        return {:error => "Cannot request more than 2 days of transactions if not account is specified"}
      end
      response = @client.call(:generate_xml_extract, :message => create_message(date_from, date_to, account_number, include_closed))
      return parse_cash_transactions_response(response) if response.success?
      {:error => "An error has occured, please try again later"}
    end

private

    def create_message(date_from, date_to, account_number, include_closed)
      {
        :string  => hash_key(Jemquarie.api_key), # base64 encoded of the sha1 hashed api key
        :string0 => Jemquarie.app_key,
        :string1 => hash_key(@username),
        :string2 => hash_key(@password),
        :string3 => 'your.clients Transactions',
        :string4 => 'V1.4',
        :strings => [
          {
            :item0 => account_number,                          # Account Number
            :item1 => date_from.strftime("%Y-%m-%dT%H:%M:%S"), # START DATE
            :item2 => date_to.strftime("%Y-%m-%dT%H:%M:%S"),   # TO DATE
            :item3 => include_closed                           # Include closed accounts flag
          }
        ]
      }
    end

  end

end
