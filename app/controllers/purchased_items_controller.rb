class PurchasedItemsController < ApplicationController
    before_action :require_logged_in
    layout 'purchased_items'
    require 'will_paginate/array'

    #NEED VALIDATION FOR NOT BEING ABLE TO BUY THE SAME SHOE TWICE

    def new
      @user = current_user
      @product = Product.find(params[:id])
      if current_user.id == @product.seller_id
        flash[:user_error] = "* You cannot buy your own item *"
        redirect_to product_path(@product)
      else
        render :new
      end
    end

    def create
      purchased_item = PurchasedItem.new(purchase_params)
      if purchased_item.save
        product = purchased_item.product
        product.purchased_item_id = purchased_item.id
        product.save
        product.pending_carts.destroy_all
        redirect_to purchased_items_path
      else
        flash[:user_error] = purchased_item.errors.full_messages
        redirect_back fallback_location: products_path
      end
    end

    def index
      purchased_items = PurchasedItem.all.select{|t| t.buyer_id == current_user.id}
      @purchased_items  = purchased_items.paginate(page: params[:page], per_page: 5)
    end

    private

    def purchase_params
        params.require(:purchased_item).permit(:buyer_id, :product_id)
    end

end
