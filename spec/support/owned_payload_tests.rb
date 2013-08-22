module OwnedPayloadTests
  extend ActiveSupport::Concern

  included do
    let(:owner1) { create(:user) }
    let(:owner2) { create(:user) }

    describe "GET /owned_payload_path" do
      it 'returns 200 on success' do
        get api("/#{owned_payload_path}")
        expect(response.status).to eq 200
      end

      it 'returns owned payloads array' do
        get api("/#{owned_payload_path}")
        expect(response.status).to eq 200
        expect(json_response).to be_an Array
        expect(json_response.size).to eq 2

        expect(json_response[0]).to owned_payload_eq owned_payload1
        expect(json_response[1]).to owned_payload_eq owned_payload2
      end
    end

    describe "GET /owned_payload_path/owned/payload/name" do
      it 'returns 200 on success' do
        get api("/#{owned_payload_path}/#{owned_payload1.name}")
        expect(response.status).to eq 200
      end

      it 'returns owned payload' do
        get api("/#{owned_payload_path}/#{owned_payload1.name}")
        expect(json_response).to owned_payload_eq owned_payload1
      end

      it 'return 404 Not Found on owned payload not found' do
        get api("/#{owned_payload_path}/non/existing/owned/payload")
        expect(response.status).to eq 404
      end
    end

    describe "GET /owned_payload_path/owned/payload/name/payload" do
      it 'returns 200 on success' do
        get api("/#{owned_payload_path}/#{owned_payload1.name}/payload")
        expect(response.status).to eq 200
      end

      it 'returns payload' do
        get api("/#{owned_payload_path}/#{owned_payload1.name}/payload")
        expect(response.content_type).to eq 'text/plain'
        expect(response.body).to eq owned_payload1.payload
      end

      it 'return 404 Not Found on owned payload not found' do
        get api("/#{owned_payload_path}/non/existing/owned/payload/name/payload")
        expect(response.status).to eq 404
      end
    end

    describe "POST /owned_payload_path" do
      context 'when unauthenticated' do
        it 'returns 401 authentication error' do
          post api("/#{owned_payload_path}")
          expect(response.status).to eq 401
        end
      end

      context 'when authenticated as user' do
        it 'returns 201 Created on new owned payload created' do
          post api("/#{owned_payload_path}", owner1), new_owned_payload
          expect(response.status).to eq 201
        end

        it 'creates new owned payload' do
          expect {
            post api("/#{owned_payload_path}", owner1), new_owned_payload
          }.to change { owned_payload_class.count }.by(1)
        end

        it 'creates new owned payload with owner set to user' do
          post api("/#{owned_payload_path}", owner1), new_owned_payload
          expect(owned_payload_class.find_by(name: new_owned_payload[:name]).users).to include owner1
        end

        it 'creates new owned payload with given owner list' do
          post api("/#{owned_payload_path}", owner1), new_owned_payload_with_owners
          created_owned_payload = owned_payload_class.find_by(name: new_owned_payload_with_owners[:name])
          expect(created_owned_payload.users).to include owner1
          expect(created_owned_payload.users).to include owner2
        end

        it 'returns 400 Bad Request when name is missing' do
          post api("/#{owned_payload_path}", owner1), {payload: 'payload'}
          expect(response.status).to eq 400
        end

        it 'returns 400 Bad Request when name format is incorect' do
          post api("/#{owned_payload_path}", owner1), {name: 'wrong\name'}
          expect(response.status).to eq 400
        end

        it 'returns 400 Bad Request when payload is missing' do
          post api("/#{owned_payload_path}", owner1), {name: 'new/owned_payload'}
          expect(response.status).to eq 400
        end
      end
    end

    describe "PUT /owned_payload_path/owned_payload/name" do
      context 'when unauthenticated' do
        it 'returns 401 authentication error' do
          put api("/#{owned_payload_path}/#{owned_payload1.name}")
          expect(response.status).to eq 401
        end
      end

      context 'when authenticated as user' do
        it 'returns 200 on success' do
          put api("/#{owned_payload_path}/#{owned_payload1.name}", owner1)
          expect(response.status).to eq 200
        end

        it 'updates owned payload payload' do
          new_payload = 'new payload'
          put api("/#{owned_payload_path}/#{owned_payload1.name}", owner1), {payload: new_payload}
          expect(json_response['payload']).to eq new_payload
        end

        it 'updates owned payload owners' do
          new_payload = 'new payload'
          put api("/#{owned_payload_path}/#{owned_payload1.name}", owner1), {owners: [owner2.login]}
          updated_owned_payload = owned_payload_class.find(owned_payload1.id)
          expect(updated_owned_payload.users).to include owner2
          expect(updated_owned_payload.users).to_not include owner1
        end

        it 'returns 404 on owned payload not found' do
          put api("/#{owned_payload_path}/non/existing", owner1)
          expect(response.status).to eq 404
        end

        it 'returns 403 Forbidden when user is not owned payload owner' do
          put api("/#{owned_payload_path}/#{owned_payload2.name}", owner2)
          expect(response.status).to eq 403
        end
      end
    end

    describe "DELETE /owned_payload_path/owned_payload/name" do
      context 'when unauthenticated' do
        it 'returns 401 authentication error' do
          delete api("/#{owned_payload_path}/#{owned_payload2.name}")
          expect(response.status).to eq 401
        end

         context 'when authenticated as user' do
          it 'returns 200 on success' do
            delete api("/#{owned_payload_path}/#{owned_payload2.name}", owner1)
            expect(response.status).to eq 200
          end

          it 'returns 403 Forbidden when user is not owned payload owner' do
            delete api("/#{owned_payload_path}/#{owned_payload2.name}", owner2)
            expect(response.status).to eq 403
          end
        end
      end
    end
  end
end