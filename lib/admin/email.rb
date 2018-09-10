require 'net/smtp'

module AdminUI
  class EMail
    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def configured?
      @config.sender_email_server &&
        @config.sender_email_account &&
        @config.receiver_emails &&
        !@config.receiver_emails.empty?
    end

    def send_email(disconnected)
      return unless configured? && !disconnected.empty?

      recipients = @config.receiver_emails.join(', ')
      title      = email_title(disconnected)
      email      = email_content(recipients,
                                 title,
                                 email_table_rows(disconnected))

      begin
        Net::SMTP.start(@config.sender_email_server,
                        @config.sender_email_port,
                        @config.sender_email_domain,
                        @config.sender_email_account,
                        @config.sender_email_secret,
                        @config.sender_email_authtype) do |smtp|
          smtp.send_message(email,
                            @config.sender_email_account,
                            @config.receiver_emails)
        end

        @logger.debug("Email '#{title}' sent to #{recipients}")
      rescue => error
        @logger.error("Error sending email '#{title}' to addresses #{recipients}: #{error}")
      end
    end

    private

    def email_title(disconnected)
      title = "[#{@config.cloud_controller_uri}] "

      title += if disconnected.length == 1
                 "#{disconnected.first['type']} is down"
               else
                 'Multiple Cloud Foundry components are down'
               end

      title
    end

    def email_table_rows(disconnected)
      rows = ''
      disconnected.each do |item|
        rows += "<tr style='background-color: rgb(230, 230, 230); color: rgb(35, 35, 35);'>"
        rows += "  <td style='border: 1px solid rgb(100, 100, 100);'>#{item['type']}</td>"
        rows += "  <td style='border: 1px solid rgb(100, 100, 100);'>#{item['uri']}</td>"
        rows += '</tr>'
      end

      rows
    end

    def email_content(recipients, title, rows)
      <<~EMAIL_CONTENT
        From: #{@config.sender_email_account}
        To: #{recipients}
        Importance: High
        MIME-Version: 1.0
        Content-type: text/html
        Subject: #{title}

        <div style="font-family: verdana,tahoma,sans-serif; font-size: .9em; color: rgb(35, 35, 35);">
          <div style="font-weight: bold; margin-bottom: 1em;">Cloud Controller: #{@config.cloud_controller_uri}</div>
          <div style="margin-bottom: .7em;">The following Cloud Foundry components are down:</div>
        </div>

        <table cellpadding="5" style="border-collapse: collapse; border: 1px solid rgb(100, 100, 100); font-family: verdana,tahoma,sans-serif; font-size: .9em">
          <tr style="background-color: rgb(150, 160, 170); color: rgb(250, 250, 250); border: 1px solid rgb(100, 100, 100);">
            <th style="border: 1px solid rgb(100, 100, 100);">Type</th>
            <th style="border: 1px solid rgb(100, 100, 100);">URI</th>
          </tr>
          #{rows}
        </table>
      EMAIL_CONTENT
    end
  end
end
