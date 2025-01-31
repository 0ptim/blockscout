defmodule BlockScoutWeb.API.V2.Helper do
  @moduledoc """
    API V2 helper
  """

  alias Ecto.Association.NotLoaded
  alias Explorer.Chain.Address
  alias Explorer.Chain.Transaction.History.TransactionStats

  import BlockScoutWeb.Account.AuthController, only: [current_user: 1]
  import BlockScoutWeb.Models.GetAddressTags, only: [get_address_tags: 3]

  def address_with_info(conn, address, address_hash, tags_needed?, watchlist_names_cached \\ nil)

  def address_with_info(_, _, nil, _, _) do
    nil
  end

  def address_with_info(conn, address, address_hash, true, nil) do
    %{
      common_tags: public_tags,
      personal_tags: private_tags,
      watchlist_names: watchlist_names
    } = get_address_tags(address_hash, current_user(conn), api?: true)

    Map.merge(address_with_info(address, address_hash), %{
      "private_tags" => private_tags,
      "watchlist_names" => watchlist_names,
      "public_tags" => public_tags
    })
  end

  def address_with_info(_conn, address, address_hash, false, nil) do
    Map.merge(address_with_info(address, address_hash), %{
      "private_tags" => [],
      "watchlist_names" => [],
      "public_tags" => []
    })
  end

  def address_with_info(_conn, address, address_hash, _, watchlist_names_cached) do
    watchlist_name = watchlist_names_cached[address_hash]

    Map.merge(address_with_info(address, address_hash), %{
      "private_tags" => [],
      "watchlist_names" => if(watchlist_name, do: [watchlist_name], else: []),
      "public_tags" => []
    })
  end

  @doc """
  Gets address with the additional info for api v2
  """
  @spec address_with_info(any(), any()) :: nil | %{optional(<<_::32, _::_*8>>) => any()}
  def address_with_info(%Address{} = address, _address_hash) do
    %{
      "hash" => Address.checksum(address),
      "is_contract" => Address.is_smart_contract(address),
      "name" => address_name(address),
      "implementation_name" => implementation_name(address),
      "is_verified" => is_verified(address),
      "ens_domain_name" => address.ens_domain_name
    }
  end

  def address_with_info(%{ens_domain_name: name}, address_hash) do
    nil
    |> address_with_info(address_hash)
    |> Map.put("ens_domain_name", name)
  end

  def address_with_info(%NotLoaded{}, address_hash) do
    address_with_info(nil, address_hash)
  end

  def address_with_info(nil, nil) do
    nil
  end

  def address_with_info(_, address_hash) do
    %{
      "hash" => Address.checksum(address_hash),
      "is_contract" => false,
      "name" => nil,
      "implementation_name" => nil,
      "is_verified" => nil
    }
  end

  def address_name(%Address{names: [_ | _] = address_names}) do
    case Enum.find(address_names, &(&1.primary == true)) do
      nil ->
        %Address.Name{name: name} = Enum.at(address_names, 0)
        name

      %Address.Name{name: name} ->
        name
    end
  end

  def address_name(_), do: nil

  def implementation_name(%Address{smart_contract: %{implementation_name: implementation_name}}),
    do: implementation_name

  def implementation_name(_), do: nil

  def is_verified(%Address{smart_contract: nil}), do: false
  def is_verified(%Address{smart_contract: %{metadata_from_verified_twin: true}}), do: false
  def is_verified(%Address{smart_contract: %NotLoaded{}}), do: nil
  def is_verified(%Address{smart_contract: _}), do: true

  def market_cap(:standard, %{available_supply: available_supply, usd_value: usd_value, market_cap_usd: market_cap_usd})
      when is_nil(available_supply) or is_nil(usd_value) do
    max(Decimal.new(0), market_cap_usd)
  end

  def market_cap(:standard, %{available_supply: available_supply, usd_value: usd_value}) do
    Decimal.mult(available_supply, usd_value)
  end

  def market_cap(module, exchange_rate) do
    module.market_cap(exchange_rate)
  end

  def get_transaction_stats do
    stats_scale = date_range(1)
    transaction_stats = TransactionStats.by_date_range(stats_scale.earliest, stats_scale.latest)

    # Need datapoint for legend if none currently available.
    if Enum.empty?(transaction_stats) do
      [%{number_of_transactions: 0, gas_used: 0}]
    else
      transaction_stats
    end
  end

  def date_range(num_days) do
    today = Date.utc_today()
    latest = Date.add(today, -1)
    x_days_back = Date.add(latest, -1 * (num_days - 1))
    %{earliest: x_days_back, latest: latest}
  end
end
