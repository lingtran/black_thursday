require_relative '../test/test_helper'

require 'pry'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/merchant'
require_relative '../lib/merchant_repository'
require_relative '../lib/item'
require_relative '../lib/item_repository'
require_relative '../lib/sales_engine'
require_relative '../lib/sales_analyst'
require_relative '../lib/invoice'
require_relative '../lib/invoice_repository'
require_relative '../lib/transaction'
require_relative '../lib/transaction_repository'
require_relative '../lib/customer'
require_relative '../lib/customer_repository'
require_relative '../lib/invoice_item'
require_relative '../lib/invoice_item_repository'

class SalesAnalystTest < Minitest::Test

  attr_reader :sales_engine, :sales_analyst
  def setup
    @sales_engine = SalesEngine.from_csv({
      :items     => "data/items.csv",
      :merchants => "data/merchants.csv",
      :invoices => "data/invoices.csv",
      :invoice_items => 'data/invoice_items.csv',
      :transactions => 'data/transactions.csv',
      :customers => 'data/customers.csv'
    })
    @sales_analyst = SalesAnalyst.new(sales_engine)
  end

  def test_sales_analyst_can_be_instantiated_with_sales_engine
    assert sales_analyst.is_a?(SalesAnalyst)
  end

  def test_can_calculate_average_items_per_merchant
    assert_equal 2.88, sales_analyst.average_items_per_merchant
  end

  def test_can_find_squared_difference_for_average_items_per_merchant
    assert_equal 5034.919999999962, sales_analyst.find_squared_difference(sales_engine.merchants.item_count_per_merchant_hash, sales_analyst.average_items_per_merchant)
  end

  def test_can_find_sample_for_average_items_per_merchant
    assert_equal 474, sales_analyst.find_sample(sales_engine.merchants.all.count)
    assert_equal 1366, sales_analyst.find_sample(sales_engine.items.all.count)
  end

  def test_can_find_standard_deviation_for_average_items_per_merchant_standard_deviation
    assert_equal 3.26, sales_analyst.find_standard_deviation(sales_engine.merchants.item_count_per_merchant_hash, sales_analyst.average_items_per_merchant,sales_engine.merchants.all.count)
  end

  def test_can_calculate_average_items_per_merchant_standard_deviation
    assert_equal 3.26, sales_analyst.average_items_per_merchant_standard_deviation
  end

  def test_can_calculate_number_for_one_std_dev_for_average_items_per_merchant
    assert_equal 6.14, sales_analyst.one_std_dev_for_average_items_per_merchant
  end

  def test_can_calculate_merchants_more_than_one_std_dev_from_avg_number_of_products_offered
    assert_equal 52, sales_analyst.merchants_with_high_item_count.count
  end

  def test_can_calculate_average_item_price_for_specific_merchant_id_for_merchants_with_high_item_count
    assert_equal BigDecimal, sales_analyst.average_item_price_for_merchant(12334105).class
    assert_equal 16.66, sales_analyst.average_item_price_for_merchant(12334105).to_f.round(2)
  end

  def test_can_calculate_sum_of_all_the_averages_to_find_average_price_across_all_merchants
    assert_equal BigDecimal, sales_analyst.average_average_price_per_merchant.class
    assert_equal 350.29, sales_analyst.average_average_price_per_merchant.to_f.round(2)
  end

  def test_can_find_squared_difference_for_average_item_price
    sales_engine = SalesEngine.from_csv({
      :items     => "test/fake_items.csv",
      :merchants => "test/fake_merchants.csv",
      :invoices => "data/invoices.csv",
      :customers => "test/fake_customers.csv",
      :transactions => 'data/transactions.csv',
      :invoice_items => 'data/invoice_items.csv'

    })
    sales_analyst = SalesAnalyst.new(sales_engine)
    assert_equal 7.684705882352941, sales_analyst.find_squared_difference(sales_engine.items.item_unit_price_hash, sales_analyst.average_price_of_all_items)
  end

  def test_can_find_standard_deviation_for_average_item_price
    sales_engine = SalesEngine.from_csv({
      :items     => "test/fake_items.csv",
      :merchants => "test/fake_merchants.csv",
      :invoices => "data/invoices.csv",
      :customers => "test/fake_customers.csv",
      :transactions => 'data/transactions.csv',
      :invoice_items => 'data/invoice_items.csv'

    })
    sales_analyst = SalesAnalyst.new(sales_engine)
    assert_equal 0.69, sales_analyst.find_standard_deviation(sales_engine.items.item_unit_price_hash, sales_analyst.average_price_of_all_items, sales_engine.items.all.count)
  end

  def test_can_calculate_average_item_price_standard_deviation
    sales_engine = SalesEngine.from_csv({
      :items     => "test/fake_items.csv",
      :merchants => "test/fake_merchants.csv",
      :invoices => "data/invoices.csv",
      :customers => "test/fake_customers.csv",
      :transactions => 'data/transactions.csv',
      :invoice_items => 'data/invoice_items.csv'

    })
    sales_analyst = SalesAnalyst.new(sales_engine)
    assert_equal 0.69, sales_analyst.average_item_price_standard_deviation
  end

  def test_can_calculate_number_for_two_std_dev_for_average_item_price
    sales_engine = SalesEngine.from_csv({
      :items     => "test/fake_items.csv",
      :merchants => "test/fake_merchants.csv",
      :invoices => "data/invoices.csv",
      :customers => "test/fake_customers.csv",
      :transactions => 'data/transactions.csv',
      :invoice_items => 'data/invoice_items.csv'

    })
    sales_analyst = SalesAnalyst.new(sales_engine)
    assert_equal 153.22, sales_analyst.two_std_dev_for_average_item_price
  end

  def test_can_calculate_golden_items
    sales_engine = SalesEngine.from_csv({
      :items     => "test/fake_items.csv",
      :merchants => "test/fake_merchants.csv",
      :invoices => "data/invoices.csv",
      :customers => "test/fake_customers.csv",
      :transactions => 'data/transactions.csv',
      :invoice_items => 'data/invoice_items.csv'

    })
    sales_analyst = SalesAnalyst.new(sales_engine)
    assert_equal 0, sales_analyst.golden_items.count
  end

  def test_can_calculate_average_invoices_per_merchant
    expected = 10.49
    assert_equal expected, sales_analyst.average_invoices_per_merchant
    assert_equal Float, expected.class
  end

  def test_can_calculate_squared_difference_for_average_invoices_per_merchant
    assert_equal 5132.74749999999, sales_analyst.find_squared_difference(sales_engine.merchants.invoice_count_per_merchant_hash, sales_analyst.average_invoices_per_merchant)
  end

  def test_can_find_standard_deviation_for_average_invoices_per_merchant
    assert_equal 3.29, sales_analyst.find_standard_deviation(sales_engine.merchants.invoice_count_per_merchant_hash, sales_analyst.average_invoices_per_merchant, sales_engine.merchants.all.count)
  end

  def test_can_calculate_average_invoices_per_merchant_standard_deviation
    assert_equal 3.29, sales_analyst.average_invoices_per_merchant_standard_deviation
    assert_equal Float, sales_analyst.average_invoices_per_merchant_standard_deviation.class
  end

  def test_can_calculate_two_std_dev_average_invoice_count
    expected = 6.58
    assert_equal expected, sales_analyst.two_std_dev_average_invoice_count
  end

  def test_can_calculate_number_for_two_std_dev_above_average_invoice_count
    expected = 17.07
    assert_equal expected, sales_analyst.two_std_dev_above_average_invoice_count
    assert_equal Float, expected.class
  end

  def test_can_calculate_two_std_dev_below_average_invoice_count
    expected = 3.91
    assert_equal expected, sales_analyst.two_std_dev_below_average_invoice_count
    assert_equal Float, expected.class
  end

  def test_can_calculate_top_performing_merchants
    expected = sales_analyst.top_merchants_by_invoice_count
    assert_equal 12, expected.count
    assert_equal Merchant, expected.first.class
  end

  def test_can_calculate_lowest_performing_merchants
    expected = sales_analyst.bottom_merchants_by_invoice_count
    assert_equal 4, expected.count
    assert_equal Merchant, expected.first.class
  end

  def test_can_calculate_average_invoices_per_day
    expected = sales_analyst.average_invoices_per_day
    assert_equal 712, expected
  end

  def test_can_calculate_average_invoices_per_day_standard_deviation
    assert_equal 18.07, sales_analyst.average_invoices_per_day_standard_deviation
    assert_equal Float, sales_analyst.average_invoices_per_day_standard_deviation.class
  end

  def test_can_calculate_one_std_dev_above_average_invoice_count_per_day
    assert_equal 730.07, sales_analyst.one_std_dev_above_average_invoice_count
    assert_equal Float, sales_analyst.one_std_dev_above_average_invoice_count.class
  end

  def test_can_calculate_which_days_of_the_week_see_the_most_sales
    expected = sales_analyst.top_days_by_invoice_count
    assert_equal 1, expected.count
    assert_equal "Wednesday", expected.first
    assert_equal String, expected.first.class
  end

  def test_we_can_get_the_percent_of_invoices_that_have_a_certain_status
    sales_engine = SalesEngine.from_csv({
      :items     => "test/fake_items.csv",
      :merchants => "test/fake_merchants.csv",
      :invoices => "data/invoices.csv",
      :customers => "test/fake_customers.csv",
      :transactions => 'data/transactions.csv',
      :invoice_items => 'data/invoice_items.csv'

    })
    sales_analyst = SalesAnalyst.new(sales_engine)
    assert_equal 29.55, sales_analyst.invoice_status(:pending)
    assert_equal 56.95, sales_analyst.invoice_status(:shipped)
    assert_equal 13.5, sales_analyst.invoice_status(:returned)
  end

  def test_can_calculate_total_rev_by_date
    date = Time.parse("2009-02-07")
    assert_equal 21067.77, sales_analyst.total_revenue_by_date(date).to_f.round(2)
  end

  def test_can_calculate_top_x_performing_merchants_in_terms_of_revenue
    assert_equal 20, sales_analyst.top_revenue_earners.count
    assert_equal 10, sales_analyst.top_revenue_earners(10).count
  end

  def test_can_find_merchants_with_pending_invoices
    assert_equal 467, sales_analyst.merchants_with_pending_invoices.count
  end

  def test_can_find_merchants_with_only_one_item
    assert_equal 243, sales_analyst.merchants_with_only_one_item.count
  end

  def test_can_find_merchants_with_only_one_item_registered_in_month
    assert_equal 21, sales_analyst.merchants_with_only_one_item_registered_in_month("March").count
    assert_equal 18, sales_analyst.merchants_with_only_one_item_registered_in_month("June").count
  end

  def test_can_find_revenue_by_merchant
    assert_equal BigDecimal, sales_analyst.revenue_by_merchant(12334194).class
  end

  def test_can_rank_merchant_by_revenue
    assert_equal Array, sales_analyst.merchants_ranked_by_revenue.class
    assert_equal 12334634, sales_analyst.merchants_ranked_by_revenue.first.id
  end

  def test_can_find_most_sold_item_for_merchant
    assert sales_analyst.most_sold_item_for_merchant(12334189).map { |item| item.id }.include?(263524984)
    assert_equal 263549386, sales_analyst.most_sold_item_for_merchant(12334768).first.id
    assert_equal 4, sales_analyst.most_sold_item_for_merchant(12337105).count
    assert_equal [263431273, 263531354, 263463003, 263540734], sales_analyst.most_sold_item_for_merchant(12337105).map { |item| item.id }
  end

  def test_can_find_item_that_generates_most_revenue_for_a_merchant
    assert_equal 263516130, sales_analyst.best_item_for_merchant(12334189).id
  end
end
