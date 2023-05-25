defmodule PaymentChallangeWeb.Router do
  use PaymentChallangeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PaymentChallangeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PaymentChallangeWeb do
    pipe_through :browser

    get "/", PaymentController, :index
    post "/payment", PaymentController, :accept_payment
    put "/block_count", PaymentController, :update_block_count
  end
end
