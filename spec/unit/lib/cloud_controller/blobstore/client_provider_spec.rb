require 'spec_helper'

module CloudController
  module Blobstore
    describe ClientProvider do
      let(:options) { { blobstore_type: blobstore_type } }

      context 'when no type is requested' do
        let(:blobstore_type) { nil }

        before do
          options.merge!(fog_connection: {})
        end

        it 'provides a fog client' do
          expect(ClientProvider.provide(options: options, directory_key: 'key').wrapped_client).to be_a(FogClient)
        end
      end

      context 'when fog is requested' do
        let(:blobstore_type) { 'fog' }

        before do
          options.merge!(fog_connection: {})
        end

        it 'provides a fog client' do
          expect(ClientProvider.provide(options: options, directory_key: 'key').wrapped_client).to be_a(FogClient)
        end

        context 'when a cdn is requested in the options' do
          before do
            options.merge!(cdn: { uri: 'http://cdn.com' })
          end

          it 'sets up a cdn for the fog client' do
            allow(FogClient).to receive(:new).and_call_original

            expect(ClientProvider.provide(options: options, directory_key: 'key').wrapped_client).to be_a(FogClient)

            expect(FogClient).to have_received(:new).with(anything, anything, an_instance_of(Cdn), anything, anything, anything)
          end
        end

        context 'when fog_connection is not provided' do
          before do
            options.delete(:fog_connection)
          end

          it 'raises an error' do
            expect { ClientProvider.provide(options: options, directory_key: 'key') }.to raise_error(KeyError)
          end
        end
      end

      context 'when webdav is requested' do
        let(:blobstore_type) { 'webdav' }

        before do
          options.merge!(webdav_config: {})
        end

        it 'provides a webdav client' do
          expect(ClientProvider.provide(options: options, directory_key: 'key').wrapped_client).to be_a(DavClient)
        end
      end
    end
  end
end
