# frozen_string_literal: true

class EmailTemplate
  EMAIL_TEMPLATE_DETAILS = {
    'welcome' => {
      required_user_attributes: %i[name],
      template: {
        subject: 'Welcome to Our Service!',
        body: "Hello %<user_name>s,\n\nThank you for joining us!",
        from: 'noreply@example.com',
        template: 'welcome.html'
      }
    },
    'password_reset' => {
      required_user_attributes: %i[name],
      template: {
        subject: 'Password Reset Request',
        body: "Hello %<user_name>s,\n\nClick here to reset your password.",
        from: 'security@example.com',
        template: 'password_reset.html'
      }
    },
    'order_confirmation' => {
      required_user_attributes: %i[name order_id],
      template: {
        subject: 'Order Confirmation #%<user_order_id>s',
        body: "Hello %<user_name>s,\n\nYour order has been confirmed.",
        from: 'orders@example.com',
        template: 'order.html'
      }
    },
    'newsletter' => {
      required_user_attributes: %i[name],
      template: {
        subject: 'Monthly Newsletter',
        body: "Hello %<user_name>s,\n\nHere\'s our monthly update.",
        from: 'newsletter@example.com',
        template: 'newsletter.html'
      }
    }
  }.freeze

  def initialize(type, user)
    raise ArgumentError, 'Invalid email template type' unless valid_type?(type)
    raise ArgumentError, 'Required user attribute(s) not present' unless required_user_attributes_present?(type, user)

    @email_template_detail = EMAIL_TEMPLATE_DETAILS[type][:template]
    @user = user
  end

  def generate
    {
      to: @user[:email],
      from: @email_template_detail[:from],
      subject: interpolate_email_template_detail_subject,
      body: interpolate_email_template_detail_body,
      template: @email_template_detail[:template],
      format: user_format_preference
    }
  end

  private

  def valid_type?(type)
    EMAIL_TEMPLATE_DETAILS.key?(type)
  end

  def required_user_attributes_present?(type, user)
    EMAIL_TEMPLATE_DETAILS[type][:required_user_attributes].all? do |required_user_attribute|
      user.key?(required_user_attribute)
    end
  end

  def interpolate_email_template_detail_subject
    format(@email_template_detail[:subject], user_order_id: @user[:order_id])
  end

  def interpolate_email_template_detail_body
    format(@email_template_detail[:body], user_name: @user[:name])
  end

  def user_format_preference
    @user.dig(:preferences, :html_emails) ? 'html' : 'text'
  end
end

class EmailNotifier
  def send_email(type, user)
    if type == 'welcome'
      subject = 'Welcome to Our Service!'
      body = "Hello #{user[:name]},\n\nThank you for joining us!"
      send_to = user[:email]
      from = 'noreply@example.com'
      template = 'welcome.html'
    elsif type == 'password_reset'
      subject = 'Password Reset Request'
      body = "Hello #{user[:name]},\n\nClick here to reset your password."
      send_to = user[:email]
      from = 'security@example.com'
      template = 'password_reset.html'
    elsif type == 'order_confirmation'
      subject = "Order Confirmation ##{user[:order_id]}"
      body = "Hello #{user[:name]},\n\nYour order has been confirmed."
      send_to = user[:email]
      from = 'orders@example.com'
      template = 'order.html'
    elsif type == 'newsletter'
      subject = 'Monthly Newsletter'
      body = "Hello #{user[:name]},\n\nHere's our monthly update."
      send_to = user[:email]
      from = 'newsletter@example.com'
      template = 'newsletter.html'
    else
      return false
    end

    mail = {}
    mail[:to] = send_to
    mail[:from] = from
    mail[:subject] = subject
    mail[:body] = body
    mail[:template] = template

    mail[:format] = if user[:preferences] && user[:preferences][:html_emails] == false
                      'text'
                    else
                      'html'
                    end

    puts "Sending email: #{mail}"
    true
  end
end
