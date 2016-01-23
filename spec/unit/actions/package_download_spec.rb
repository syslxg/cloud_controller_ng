require 'spec_helper'
require 'actions/package_download'

module VCAP::CloudController
  describe PackageDownload do
    subject(:package_download) { PackageDownload.new }
    let(:blobstore_client) { instance_double(CloudController::Blobstore::Client) }

    before do
      allow(CloudController::DependencyLocator.instance).to receive(:package_blobstore).and_return(blobstore_client)
    end

    describe '#download' do
      let(:package) do
        PackageModel.make(

          state: 'READY',
          type:  'BITS',
        )
      end

      let(:download_location) { 'http://package.download.url' }
      let(:blob_double) { instance_double(CloudController::Blobstore::FogBlob) }

      before do
        allow(blobstore_client).to receive(:blob).and_return(blob_double)
      end

      context 'the storage is not local' do
        before do
          allow(blobstore_client).to receive(:local?).and_return(false)
          allow(blob_double).to receive(:public_download_url).and_return(download_location)
        end

        it 'fetches and returns the download URL' do
          file, url = package_download.download(package)
          expect(url).to eq(download_location)
          expect(file).to be_nil
        end
      end

      context 'the storage is local' do
        before do
          allow(blobstore_client).to receive(:local?).and_return(true)
          allow(blob_double).to receive(:local_path).and_return(download_location)
        end

        it 'reports the file path' do
          file, url = package_download.download(package)
          expect(file).to eq(download_location)
          expect(url).to be_nil
        end
      end
    end
  end
end
