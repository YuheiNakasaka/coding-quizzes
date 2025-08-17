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
