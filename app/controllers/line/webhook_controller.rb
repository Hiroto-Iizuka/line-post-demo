module Line
  class WebhookController < ApplicationController
    skip_before_action :verify_authenticity_token

    def callback
      body = request.body.read
      signature = request.env["HTTP_X_LINE_SIGNATURE"]

      unless client.validate_signature(body, signature)
        Rails.logger.error "Invalid signature"
        head :bad_request
        return
      end

      events = client.parse_events_from(body)

      events.each do |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            handle_text_message(event)
          end
        end
      end

      head :ok
    end

    private

    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end

    def handle_text_message(event)
      line_user_id = event["source"]["userId"]
      text = event.message["text"]
      conversation = Conversation.find_or_initialize_by(line_user_id: line_user_id)

      case conversation.state
      when nil
        # 初回メッセージ
        conversation.state = "waiting_for_title"
        conversation.save
        message = {
          type: "text",
          text: "投稿のタイトルを入力してください"
        }
      when "waiting_for_title"
        # タイトルを受け取った
        conversation.title = text
        conversation.state = "waiting_for_content"
        conversation.save
        message = {
          type: "text",
          text: "投稿の本文を入力してください"
        }
      when "waiting_for_content"
        # 本文を受け取った
        conversation.content = text
        conversation.state = nil
        conversation.save

        # 投稿を保存
        Post.create!(
          title: conversation.title,
          content: conversation.content,
          line_user_id: line_user_id
        )

        message = {
          type: "text",
          text: "投稿が完了しました！"
        }
      end

      client.reply_message(event["replyToken"], message)
    end
  end
end
