require 'simplecov'
SimpleCov.start
gem 'minitest', '~> 5.2'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/transaction'
require_relative '../lib/transaction_repository'
require_relative '../lib/sales_engine'

class TransactionRepositoryClassTest < Minitest::Test
  attr_accessor :sales_engine
  attr_reader :transactions, :transaction_one, :transaction_two, :transaction_three

  def setup
    @sales_engine = SalesEngine.from_csv({
      :items     => "data/items.csv",
      :merchants => "data/merchants.csv",
      :invoices => "data/invoices.csv",
      :invoice_items => "data/invoice_items.csv",
      :transactions => "data/transactions.csv",
      :customers => "data/customers.csv"
    })

    @transactions = sales_engine.transactions

    @transaction_one = Transaction.new(sales_engine, {:id => '1',
      :invoice_id => '2179',
      :credit_card_number => '4068631943231473',
      :credit_card_expiration_date => '0217',
      :result => 'success',
      :created_at => '2012-02-26 20:56:56 UTC',
      :updated_at => '2012-02-26 20:56:56 UTC'})

    @transaction_two = Transaction.new(sales_engine, {:id => '2',
      :invoice_id => '46',
      :credit_card_number => '4177816490204479',
      :credit_card_expiration_date => '0813',
      :result => 'success',
      :created_at => '2012-02-26 20:56:56 UTC',
      :updated_at => '2012-02-26 20:56:56 UTC'})

    @transaction_three = Transaction.new(sales_engine, {:id => '1370',
      :invoice_id => '46',
      :credit_card_number => '4938390307931021',
      :credit_card_expiration_date => '1018',
      :result => 'success',
      :created_at => '2012-02-26 20:57:42 UTC',
      :updated_at => '2012-02-26 20:57:42 UTC'})
  end

  def test_we_can_create_an_transaction_repository
    assert transactions.is_a?(TransactionRepository)
    assert_equal 4985, transactions.all.count
  end

  def test_we_can_find_transaction_by_id
    assert_equal transaction_one.id, transactions.find_by_id(1).id
    assert_equal transaction_two.id, transactions.find_by_id(2).id
  end

  def test_we_can_find_all_transactions_by_invoice_id
    assert_equal Array, transactions.find_all_by_invoice_id(46).class
    assert_equal 2,transactions.find_all_by_invoice_id(46).first.id
    assert_equal [transaction_two.id, transaction_three.id], transactions.find_all_by_invoice_id(46).map { |transaction| transaction.id }
  end

  def test_we_can_find_all_transactions_by_credit_card_number
    assert_equal Array, transactions.find_all_by_credit_card_number(4068631943231473).class
    assert_equal 1, transactions.find_all_by_credit_card_number(4068631943231473).count
    assert_equal [transaction_one.id], transactions.find_all_by_credit_card_number(4068631943231473).map { |transaction| transaction.id }
    assert_equal Array, transactions.find_all_by_credit_card_number(4177816490204479).class
    assert_equal 1, transactions.find_all_by_credit_card_number(4177816490204479).count
    assert_equal [transaction_two.id], transactions.find_all_by_credit_card_number(4177816490204479).map { |transaction| transaction.id }
  end

  def test_can_find_transactions_according_to_their_results
    assert_equal Array, transactions.find_all_by_result("success").class
    assert_equal 4158, transactions.find_all_by_result("success").count
    assert_equal 827, transactions.find_all_by_result("failed").count
  end
end
