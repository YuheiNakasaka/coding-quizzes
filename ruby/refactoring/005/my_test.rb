require 'minitest/autorun'
require_relative 'my_answer'

class EmailNotifierTest < Minitest::Test
  def setup
    @notifier = EmailNotifier.new
    @welcome_user = {
      name: 'Alice',
      email: 'alice@example.com',
      preferences: { html_emails: true }
    }
    @password_reset_user = {
      name: 'Bob',
      email: 'bob@example.com',
      preferences: { html_emails: true }
    }
    @order_confirmation_user = {
      name: 'Charlie',
      email: 'charlie@example.com',
      order_id: '12345',
      preferences: { html_emails: true }
    }
    @newsletter_user = {
      name: 'Diana',
      email: 'diana@example.com',
      preferences: { html_emails: true }
    }
    @newsletter_user_with_non_html_format_preference = {
      name: 'Diana',
      email: 'diana@example.com',
      preferences: { html_emails: false }
    }
    @invalid_user = { name: 'Eve', email: 'eve@example.com' }
  end

  def test_send_welcome_email
    output = capture_io do
      result = @notifier.send_email('welcome', @welcome_user)
      assert result
    end

    expected_output = "Sending email: {:to=>\"alice@example.com\", :from=>\"noreply@example.com\", :subject=>\"Welcome to Our Service!\", :body=>\"Hello Alice,\\n\\nThank you for joining us!\", :template=>\"welcome.html\", :format=>\"html\"}\n"
    assert_equal expected_output, output[0]
  end

  def test_send_password_reset_email
    output = capture_io do
      result = @notifier.send_email('password_reset', @password_reset_user)
      assert result
    end

    expected_output = "Sending email: {:to=>\"bob@example.com\", :from=>\"security@example.com\", :subject=>\"Password Reset Request\", :body=>\"Hello Bob,\\n\\nClick here to reset your password.\", :template=>\"password_reset.html\", :format=>\"html\"}\n"
    assert_equal expected_output, output[0]
  end

  def test_send_order_confirmation_email
    output = capture_io do
      result = @notifier.send_email('order_confirmation', @order_confirmation_user)
      assert result
    end

    expected_output = "Sending email: {:to=>\"charlie@example.com\", :from=>\"orders@example.com\", :subject=>\"Order Confirmation #12345\", :body=>\"Hello Charlie,\\n\\nYour order has been confirmed.\", :template=>\"order.html\", :format=>\"html\"}\n"
    assert_equal expected_output, output[0]
  end

  def test_send_newsletter_email
    output = capture_io do
      result = @notifier.send_email('newsletter', @newsletter_user)
      assert result
    end

    expected_output = "Sending email: {:to=>\"diana@example.com\", :from=>\"newsletter@example.com\", :subject=>\"Monthly Newsletter\", :body=>\"Hello Diana,\\n\\nHere's our monthly update.\", :template=>\"newsletter.html\", :format=>\"html\"}\n"
    assert_equal expected_output, output[0]
  end

  def test_send_newsletter_email_with_non_html_format_preference
    output = capture_io do
      result = @notifier.send_email('newsletter', @newsletter_user_with_non_html_format_preference)
      assert result
    end

    expected_output = "Sending email: {:to=>\"diana@example.com\", :from=>\"newsletter@example.com\", :subject=>\"Monthly Newsletter\", :body=>\"Hello Diana,\\n\\nHere's our monthly update.\", :template=>\"newsletter.html\", :format=>\"text\"}\n"
    assert_equal expected_output, output[0]
  end

  def test_send_unknown_email_type_returns_false
    assert_equal false, @notifier.send_email('unknown_type', @invalid_user)
  end
end
