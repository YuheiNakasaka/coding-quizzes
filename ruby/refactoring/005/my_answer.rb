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
    with_error_handling do
      email = EmailTemplate.new(type, user).generate
      log_successful_email_delivery(email)
      true
    end
  end

  private

  def with_error_handling
    yield
  rescue ArgumentError
    log_failed_email_delivery
    false
  end

  def log_successful_email_delivery(email)
    puts "Sending email: #{email}"
  end

  def log_failed_email_delivery
    puts 'Failure sending email'
  end
end
