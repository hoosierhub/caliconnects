describe Users::RegistrationsController do
  include Devise::Test::ControllerHelpers

  context "create" do
    let(:new_sms) { double }
    let(:user_params) {
                        { user:
                              {
                                first_name: "jack",
                                last_name: "jill",
                                email: "test@example.com",
                                password: "jillsecret",
                                phone: "5005550006" },
                          street: "425",
                          route: "Market Street",
                          city: "San Francisco",
                          state: "CA",
                          zipcode: "94105"}
                      }

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]

      allow(SmsService).to receive(:new).and_return(new_sms)
      allow(new_sms).to receive(:send_message)
    end

    it "creates addresses for the users" do
      expect { post :create, params: user_params }.to change{ Address.count }.by(1)
    end

    it "sends sms to confirm user registration" do
      post :create, params: user_params

      expect(new_sms).to have_received(:send_message).with(user_params[:user][:phone], "Thanks for registering for the Shiny Fawn service! Click this link to confirm your registration: " + user_success_url)
    end
  end
end
