require 'rails_helper'

RSpec.describe 'TransferService' do
  self.use_transactional_tests = false

  before(:each) do
    @from_user = create(:user)
    @to_user = create(:user)
  end

  context 'user has enough money to make a transfer' do
    it 'then users balances are updated' do
      expect(
        TransferService.call(@from_user.id, @to_user.id, 30.0)
      ).to be true

      @from_user.reload
      expect(@from_user.balance).to eq(20.0)

      @to_user.reload
      expect(@to_user.balance).to eq(80.0)
    end
  end

  context "user doesn't have enough money to make a transfer" do
    it 'then user gets ArgumentError' do
      expect {
        TransferService.call(@from_user.id, @to_user.id, 60.0)
      }.to raise_error(ArgumentError)

      @from_user.reload
      expect(@from_user.balance).to eq(50.0)

      @to_user.reload
      expect(@to_user.balance).to eq(50.0)
    end
  end

  context 'TransferService is used in separate threads' do
    context 'user has enough money to make transfers' do
      it 'then all transactions are successful', bypass_cleaner: true do
        threads_count = 2
        threads = []

        threads_count.times do
          threads << Thread.new do
            TransferService.call(@from_user.id, @to_user.id, 20.0)
          end
        end

        threads.each(&:join)

        @from_user.reload
        expect(@from_user.balance).to eq(10.0)

        @to_user.reload
        expect(@to_user.balance).to eq(90.0)
      end
    end

    context "user doesn't have enough money to make transfers" do
      it 'then some transaction are failed', bypass_cleaner: true do
        threads_count = 4
        threads = []

        errors_count = 0

        threads_count.times do
          threads << Thread.new do
            begin
              TransferService.call(@from_user.id, @to_user.id, 20.0)
            rescue ArgumentError
              errors_count += 1
            end
          end
        end

        threads.each(&:join)

        expect(errors_count).to eq(2)

        @from_user.reload
        expect(@from_user.balance).to eq(10.0)

        @to_user.reload
        expect(@to_user.balance).to eq(90.0)
      end
    end
  end

  context 'TransferService is used in separate processes' do
    context 'user has enough money to make transfers' do
      it 'then all transactions are successful', bypass_cleaner: true do
        processes_count = 2

        processes_count.times do
          Process.fork do
            TransferService.call(@from_user.id, @to_user.id, 20.0)
          end
        end

        Process.waitall

        @from_user.reload
        expect(@from_user.balance).to eq(10.0)

        @to_user.reload
        expect(@to_user.balance).to eq(90.0)
      end
    end
  end

  context 'TransferService is used in separate processes' do
    context "user doesn't have enough money to make transfers" do
      it 'then some transaction are failed', bypass_cleaner: true do
        processes_count = 3

        read_stream, write_stream = IO.pipe

        processes_count.times do
          Process.fork do
            begin
              TransferService.call(@from_user.id, @to_user.id, 20.0)
            rescue ArgumentError
              write_stream.puts('not enough money')
            end
          end
        end

        Process.waitall
        write_stream.close
        erorr_msg = read_stream.read.strip
        read_stream.close

        expect(erorr_msg).to eq('not enough money')

        @from_user.reload
        expect(@from_user.balance).to eq(10.0)

        @to_user.reload
        expect(@to_user.balance).to eq(90.0)
      end
    end
  end
end
