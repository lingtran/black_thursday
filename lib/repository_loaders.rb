module RepositoryLoaders

  def load_items_into_repository(items)
    items.each do |row|
      @items.repository << Item.new({:id =>row[:id],
                         :name => row[:name],
                         :description => row[:description],
                         :unit_price => row[:unit_price],
                         :merchant_id => row[:merchant_id],
                         :created_at => row[:created_at],
                         :updated_at => row[:updated_at]})
    end

  end

  def load_merchants_into_repository(merchants)
    merchants.each do |row|
      @merchants.repository << Merchant.new({:id => row[:id],
                                             :name => row[:name],
                                             :created_at => row[:created_at],
                                             :updated_at => row[:updated_at]})
    end
  end

end