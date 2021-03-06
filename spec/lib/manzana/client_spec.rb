require 'ostruct'

describe Manzana::LoyaltyService do
  subject do
    Manzana::LoyaltyService.new(
      wsdl: 'https://mbsdevweb13sp3.manzanagroup.ru:8088/POSProcessing.asmx?WSDL',
      basic_auth: false,
      organization: 'ilnepartner01',
      business_unit: 'ilneshop01',
      pos: 'ilnepos01',
      org_name: 'A5',
      logger: Logger.new(STDOUT)
    )
  end

  describe '#balance_request' do
    context 'when card number is incorrect' do
      it 'returns an error' do
        VCR.use_cassette('balance_request/wrong_card_number') do
          expect(subject.balance_request(card_number: '31337')).to include(
            message: 'Карта не найдена',
            return_code: '80241'
          )
        end
      end
    end

    context 'when everything is fine' do
      it "returns card's balance" do
        VCR.use_cassette('balance_request/success') do
          expect(subject.balance_request(card_number: '2015100')).to include(
            card_active_balance: '1000.00',
            card_balance: '1000.00',
            card_discount: '0.000',
            card_number: '2015100',
            card_summ: '0.00',
            card_summ_discounted: '0.00',
            message: 'OK',
            request_id: '1234',
            return_code: '0'
          )
        end
      end
    end

    context 'when client has filled info' do
      it "it returns card balance and client full info" do
        VCR.use_cassette('balance_request/success_full') do
          expect(subject.balance_request(card_number: '201542')).to include(
            age: "115",
            birth_date: Date.new(1900, 1, 1),
            card_active_balance: "0.00",
            card_balance: "0.00",
            card_discount: "0.000",
            card_number: "201542",
            card_summ: "0.00",
            card_summ_discounted: "0.00",
            email: "i.kuznetsov@7pikes.com",
            first_name: "Константин",
            full_name: "Константин Константинопольский",
            last_name: "Константинопольский",
            level_name: "Базовый 3%",
            message: "OK",
            middle_name: "Константинович",
            phone: "+71234567890",
            request_id: "1234",
            return_code: "0",
            transaction_id: "-9223372036854774515",
          )
        end
      end
    end
  end

  describe '#cheque_request' do
    let(:item1) do
      Manzana::Data::ChequeItem.new(
        position_number: 1,
        article: 1234,
        price: 123.0,
        quantity: 2,
        summ: 246.0,
        discount: 0.0,
        summ_discounted: 246.0
      )
    end
    let(:item2) do
      Manzana::Data::ChequeItem.new(
        position_number: 2,
        article: 4321,
        price: 100.0,
        quantity: 3,
        summ: 300.0,
        discount: 10.0,
        summ_discounted: 270.0
      )
    end
    let(:cheque) do
      Manzana::Data::Cheque.new(
        card_number: '201541',
        number: '3ce05a51-e816-4825-a6a7-bcb5b80bbd0b',
        operation_type: 'Sale',
        summ: 546.0,
        discount: '0.054',
        summ_discounted: 516.0,
        paid_by_bonus: 0.0,
        items: [
          item1,
          item2
        ]
      )
    end

    context 'when soft request is made' do
      context 'when all parameters are correct' do
        it 'returns result without error' do
          VCR.use_cassette('cheque_request/soft_success') do
            expect(subject.cheque_request(type: 'Soft', cheque: cheque)).to include(
              active_charged_bonus: '0.00',
              available_payment: '0.00',
              card_active_balance: '0',
              card_balance: '0',
              card_discount: '0',
              card_number: '201541',
              card_quantity: '1',
              card_summ: '546',
              charged_bonus: '0.00',
              discount: '0.054',
              item: [
                {
                  position_number: '1',
                  article: '1234',
                  price: '123.00',
                  quantity: '2.000',
                  summ: '246.00',
                  discount: '0.000',
                  summ_discounted: '246.00',
                  available_payment: '0.00',
                  writeoff_bonus: '0.00'
                },
                {
                  position_number: '2',
                  article: '4321',
                  price: '100.00',
                  quantity: '3.000',
                  summ: '300.00',
                  discount: '10.000',
                  summ_discounted: '270.00',
                  available_payment: '0.00',
                  writeoff_bonus: '0.00'
                }
              ],
              message: 'OK',
              summ: '546.00',
              summ_discounted: '516.00',
              request_id: '1234',
              return_code: '0',
              writeoff_bonus: '0.00'
            )
          end
        end
      end
    end
  end
end
