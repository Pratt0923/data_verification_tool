class Email
attr_accessor :body, :from, :subject
  def initialize(body, from, subject)
    @body = body
    @from = from
    @subject = subject
  end
end
