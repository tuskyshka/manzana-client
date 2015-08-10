describe Manzana::Client do
  subject do
    Manzana::Client.new(
      wsdl: 'https://localhost?WSDL',
      basic_auth: false,
      organization: 'test',
      business_unit: 'test',
      pos: 'test',
      org_name: 'test'
    )
  end

  describe '#balance_request' do
    it "returns card's balance" do
      allow(subject).to receive(:balance_request).and_return(cardBalance: 100)

      expect(subject.balance_request('12345')).to eq(cardBalance: 100)
    end
  end

  describe '#cheque_request' do
    it 'returns result' do
      item1 = Manzana::ChequeItem.new(
        position_number: 1,
        article: 1234,
        price: 123.0,
        quantity: 2,
        summ: 246.0,
        discount: 0.0,
        summ_discounted: 246.0
      )
      item2 = Manzana::ChequeItem.new(
        position_number: 2,
        article: 4321,
        price: 100.0,
        quantity: 3,
        summ: 300.0,
        discount: 10.0,
        summ_discounted: 270.0
      )
      cheque = Manzana::Cheque.new(
        card_number: '12345',
        number: '12345',
        operation_type: 'Sale',
        summ: 546.0,
        discount: 0.05,
        summ_discounted: 516.0,
        paid_by_bonus: 0.0,
        items: [
          item1,
          item2
        ]
      )

      response = {
        card_balance: 516.0,
        card_activeBalance: 516.0,
        card_summ: 546.0,
        card_summDiscounted: 516.0,
        card_discount: 0.0,
        summ: 546.0,
        discount: 0.0,
        summ_discounted: 546.0,
        charged_bonus: 516.0,
        items: [
          {
            position_number: 1,
            article: 1234,
            price: 123.0,
            quantity: 2,
            summ: 246.0,
            discount: 0.0,
            summ_discounted: 246.0,
            available_payment: 0.0
          },
          {
            position_number: 2,
            article: 4321,
            price: 100.0,
            quantity: 3,
            summ: 300.0,
            discount: 10.0,
            summ_discounted: 270.0,
            available_payment: 0.0
          }
        ]
      }

      allow(subject).to receive(:cheque_request).and_return(response)

      expect(subject.cheque_request(type: 'Soft', cheque: cheque)).to eq(response)
    end
  end
end