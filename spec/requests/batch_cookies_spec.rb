require 'spec_helper'

describe BatchCookiesController do
  let(:user) { create(:user) }
  let(:oven) { user.ovens.first }

  describe 'GET new' do
    context "when not authenticated" do
      before { sign_in nil }

      it "blocks access" do
        get "/ovens/#{oven.id}/batch_cookies/new"
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "allows access" do
        get "/ovens/#{oven.id}/batch_cookies/new"
        expect(response).to_not be_a_redirect
      end

      context "when a valid oven is supplied" do
        it "assigns @oven" do
          get "/ovens/#{oven.id}/batch_cookies/new"

          expect(assigns(:oven)).to eq(oven)
        end

        it "assigns a new @cookie" do
          get "/ovens/#{oven.id}/batch_cookies/new"

          batch_cookie = assigns(:batch_cookie)
          expect(batch_cookie).to_not be_persisted
          expect(batch_cookie.storage).to eq(oven)
        end
      end

      context "when an invalid oven is supplied" do
        it "is not successful and redirects to root_path" do
          invalid_oven_id = 99999 # Use a non-existent ID here
      
          get "/ovens/#{invalid_oven_id}/batch_cookies/new"
      
          expect(flash[:alert]).to eq("Record Not Found")
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe 'POST create' do
    let(:batch_cookie_params) do
      {
        fillings: 'Vanilla',
        count: 3
      }
    end

    context "when not authenticated" do
      before { sign_in nil }

      it "blocks access" do
        post "/ovens/#{oven.id}/batch_cookies", params: { batch_cookie: batch_cookie_params }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "allows access" do
        expect {
          post "/ovens/#{oven.id}/batch_cookies", params: { batch_cookie: batch_cookie_params }
        }.to_not raise_error
      end

      context "when a valid oven is supplied" do
        it "creates a cookie for that oven" do
          expect {
            post "/ovens/#{oven.id}/batch_cookies", params: { batch_cookie: batch_cookie_params }
          }.to change{BatchCookie.count}.by(1)

          expect(BatchCookie.last.storage).to eq(oven)
        end

        it "redirects to the oven" do
          post "/ovens/#{oven.id}/batch_cookies", params: { batch_cookie: batch_cookie_params }
          expect(response).to redirect_to oven_path(oven)
        end

        it "assigns valid cookie parameters" do
          post "/ovens/#{oven.id}/batch_cookies", params: { batch_cookie: batch_cookie_params }
          expect(BatchCookie.last.fillings).to eq(batch_cookie_params[:fillings])
        end
      end

      context "when an invalid oven is supplied" do
        it "is not successful" do
          post "/ovens/#{create(:oven).id}/batch_cookies", params: { batch_cookie: batch_cookie_params }

          expect(flash[:alert]).to eq("Record Not Found")
        end
      end
    end

  end
end
