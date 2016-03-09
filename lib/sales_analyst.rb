require_relative '../lib/sales_engine'
require 'csv'
require 'pry'
require 'bigdecimal'

class SalesAnalyst
  def initialize(sales_engine)
    @sales_engine = sales_engine
  end

  def average_items_per_merchant
    (@sales_engine.items.all.count.to_f/@sales_engine.merchants.all.count.to_f).round(2)
  end

  def find_squared_difference(elements, average)
    elements.values.map do |value|
      (value - average) ** 2
    end.reduce(:+).to_f
  end

  def find_sample(sample)
    sample.to_f - 1
  end

  def find_standard_deviation(elements, average, sample)
    variance = find_squared_difference(elements, average)/find_sample(sample)
    Math.sqrt(variance).round(2)
  end

  def average_items_per_merchant_standard_deviation
    find_standard_deviation(@sales_engine.merchants.item_count_per_merchant_hash,
                            average_items_per_merchant,
                            @sales_engine.merchants.all.count)
  end

  def one_std_dev_for_average_items_per_merchant
    average_items_per_merchant_standard_deviation + average_items_per_merchant
  end

  def merchants_with_high_item_count
    one_standard_deviaton = one_std_dev_for_average_items_per_merchant
    @sales_engine.merchants.item_count_per_merchant_hash.find_all do |merchant_id, item_count|
      merchant_id if item_count > one_standard_deviaton
    end.map do |element|
          @sales_engine.merchants.find_by_id(element[0])
        end
  end

  def average_item_price_for_merchant(merchant_id)
    hash = @sales_engine.merchants.items_per_merchant_hash
    price = BigDecimal.new(hash[merchant_id].reduce(0) do |sum, item|
      sum += item.unit_price
    end)/hash[merchant_id].count
    price.round(2)
  end

  def average_average_price_per_merchant
    hash = @sales_engine.merchants.items_per_merchant_hash
    average = hash.map do |merchant, items|
      average_item_price_for_merchant(merchant)
    end.reduce(:+)/hash.count.to_f

    BigDecimal.new("#{average}").round(2)
  end

  def average_item_price_for_merchant_hash # need to test hash
    item_hash = @sales_engine.merchants.items_per_merchant_hash
    result = Hash.new
    item_hash.each_key do |merchant_id|
      result[merchant_id] = average_item_price_for_merchant(merchant_id)
    end
    result
  end

  def average_price_of_all_items
    @sales_engine.items.repository.reduce(0) do |sum, item|
      sum += item.unit_price
    end/@sales_engine.items.repository.count
  end

  def average_item_price_standard_deviation
    find_standard_deviation(@sales_engine.items.item_unit_price_hash,
                            average_price_of_all_items,
                            @sales_engine.items.all.count)
  end

  def two_std_dev_for_average_item_price
    ((average_item_price_standard_deviation * 2) + average_price_of_all_items).to_f.round(2)
  end

  def golden_items
    two_standard_deviations = two_std_dev_for_average_item_price
    @sales_engine.items.repository.find_all do |item|
      item if item.unit_price > two_standard_deviations
    end
  end

  def average_invoices_per_merchant
    (@sales_engine.invoices.repository.count.to_f/
    @sales_engine.merchants.repository.count.to_f).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    find_standard_deviation(@sales_engine.merchants.invoice_count_per_merchant_hash,
                            average_invoices_per_merchant,
                            @sales_engine.merchants.all.count)
  end

  def two_std_dev_average_invoice_count
    average_invoices_per_merchant_standard_deviation * 2
  end

  def two_std_dev_above_average_invoice_count
    (average_invoices_per_merchant + two_std_dev_average_invoice_count).to_f.round(2)
  end

  def two_std_dev_below_average_invoice_count
    (average_invoices_per_merchant - two_std_dev_average_invoice_count).to_f.round(2)
  end

  def top_merchants_by_invoice_count
    two_standard_deviations = two_std_dev_above_average_invoice_count
    @sales_engine.merchants.repository.find_all do |merchant|
      merchant if merchant.invoices.count > two_standard_deviations
    end
  end

  def bottom_merchants_by_invoice_count
    two_standard_deviations = two_std_dev_below_average_invoice_count
    @sales_engine.merchants.repository.find_all do |merchant|
      merchant if merchant.invoices.count < two_standard_deviations
    end
  end

  def average_invoices_per_day
    number_of_week_days = 7
    @sales_engine.invoices.repository.count/number_of_week_days
  end

  def average_invoices_per_day_standard_deviation
    find_standard_deviation(@sales_engine.invoices.count_of_invoices_for_day,
                            average_invoices_per_day,
                            7)
  end

  def one_std_dev_above_average_invoice_count
    average_invoices_per_day_standard_deviation + average_invoices_per_day
  end

  def top_days_by_invoice_count
    one_standard_deviation =  one_std_dev_above_average_invoice_count
    @sales_engine.invoices.count_of_invoices_for_day.find_all do |week_day, invoice_count|
      week_day if invoice_count > one_standard_deviation
    end.to_h.keys
  end

  def invoice_status(status_symbol)
    @sales_engine.invoices.percent_by_status(status_symbol)
  end

  def total_revenue_by_date(date)
    @sales_engine.invoices.find_all_by_date(date).map do |invoice|
      invoice.total
    end.reduce(:+)
  end

  def top_revenue_earners(number_of_earners = 20)
    @sales_engine.merchants.get_top_earners_by_earned_revenue(number_of_earners)
  end

  def merchants_ranked_by_revenue
    @sales_engine.merchants.sort_all_by_earned_revenue.reverse
  end

  def merchants_with_pending_invoices
    @sales_engine.merchants.merchants_with_failed_transaction
  end

  def merchants_with_only_one_item
    @sales_engine.merchants.all.find_all { |merchant| merchant.items.count == 1 }
  end

  def merchants_with_only_one_item_registered_in_month(month)
    @sales_engine.merchants.find_merchants_created_in_month(month).find_all do |merchant|
      merchant.items.count == 1
    end.uniq
  end

  def revenue_by_merchant(merchant_id)
    @sales_engine.merchants.find_by_id(merchant_id).all_revenue
  end

  def most_sold_item_for_merchant(merchant_id)
    invoice_items_for_merchant = get_invoice_items_for_merchant(merchant_id)
    max_quantity = get_highest_quantity_on_invoice_items(invoice_items_for_merchant)

    invoice_items_for_merchant.map do |invoice_item|
      invoice_item.item if invoice_item.quantity == max_quantity
    end.compact
  end

  def get_highest_quantity_on_invoice_items(invoice_items_for_merchant)
    invoice_items_for_merchant.max_by do |invoice_item|
      invoice_item.quantity
    end.quantity
  end

  def get_invoice_items_for_merchant(merchant_id)
    @sales_engine.invoices.find_all_by_merchant_id(merchant_id).map do |invoice|
      invoice.is_paid_in_full? ?
       @sales_engine.invoice_items.find_all_by_invoice_id(invoice.id) : nil
    end.compact.flatten
  end

  def make_items_and_invoice_items_hash(invoice_items_for_merchant)
    invoice_items_for_merchant.group_by do |invoice_item|
      invoice_item.item_id
    end
  end

  def make_hash_of_items_and_revenue_per_item(items_and_invoice_items_hash)
    items_and_invoice_items_hash.map do |item_id, invoice_item|
      [@sales_engine.items.find_by_id(item_id), invoice_item.reduce(0) do |revenue, invoice_item|
        revenue += invoice_item.unit_price * invoice_item.quantity
      end]
    end
  end

  def best_item_for_merchant(merchant_id)
    invoice_items_for_merchant = get_invoice_items_for_merchant(merchant_id)
    items_and_invoice_items_hash = make_items_and_invoice_items_hash(invoice_items_for_merchant)

    make_hash_of_items_and_revenue_per_item(items_and_invoice_items_hash).max_by do |revenue|
      revenue[1]
    end.first
  end

end
