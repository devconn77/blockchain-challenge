defmodule PaymentChallange.Scrapper do
  @moduledoc false

  @headers [
    {"user-agent", "challange"},
    {"content-type", "text/html"}
  ]
  @transaction_ep "https://etherscan.io/tx/"
  @verification_selector "span[id='spanTxHash']"
  @selector "span[class='u-label u-label--xs u-label--badge-in u-label--secondary ml-1']"

  @doc """
  Visits the page for given transaction hash and scrapes out the block count.
  Returns error if invalid hash given.
  """
  @spec get_block_count(binary) :: nil | integer | {:error, String.t()}
  def get_block_count(txn_hash) do
    with {:ok, %{body: html}} <- get_html(txn_hash),
         {:ok, parsed_doc} <- Floki.parse_document(html),
         true <- is_valid_page?(parsed_doc) do
      parsed_doc
      |> find_span()
      |> parse_block_count()
    else
      false ->
        {:error, "Probably invalid hash"}

      {:error, %HTTPoison.Error{}} ->
        {:error, "Etherscan Site unreachable."}

      error ->
        # error returned by Floki
        error
    end
  end

  defp get_html(txn_hash) do
    txn_hash = String.trim(txn_hash)
    HTTPoison.get(@transaction_ep <> txn_hash, @headers)
  end

  defp is_valid_page?(html) do
    case Floki.find(html, @verification_selector) do
      [] -> false
      _ -> true
    end
  end

  defp find_span(doc) do
    case Floki.find(doc, @selector) do
      # our selector will always return a list with single
      # tuple, if the span with blocks exists
      [{_, _, [block_confirmation_string]}] ->
        block_confirmation_string

      # otherwise, it could mean that the transaction is still in pending
      _ ->
        "0 block confirmations"
    end
  end

  defp parse_block_count(conf_string) do
    conf_string
    |> String.split(" ")
    |> do_parse_block_count()
  end

  defp do_parse_block_count([num, _, _]) do
    case Integer.parse(num) do
      {num, ""} when is_integer(num) -> num
      _ -> nil
    end
  end

  defp do_parse_block_count(_), do: nil
end
