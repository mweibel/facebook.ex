defmodule Facebook.ConfigTest do
  use ExUnit.Case, async: false

  alias Facebook.Config

  describe "init/1" do
    test "uses default values when no other values are specified" do
      :ok = Application.stop(:facebook)
      {:ok, _} = Application.ensure_all_started(:facebook)
      assert Config.graph_url() == "https://graph.facebook.com"
      assert Config.request_conn_timeout() == nil
    end

    test "uses values from config when they are present" do
      :ok = Application.stop(:facebook)

      set_config(%{
        graph_url: "https://graph.facebook.com/v1",
        request_conn_timeout: 100
      })

      {:ok, _} = Application.ensure_all_started(:facebook)

      assert Config.graph_url() == "https://graph.facebook.com/v1"
      assert Config.request_conn_timeout() == 100
    end

    test "reads environment variables when {:system, _} tuple is used" do
      :ok = Application.stop(:facebook)

      set_config(%{
        graph_url: {:system, "GRAPH_URL"},
        request_conn_timeout: {:system, :integer, "REQUEST_CONN_TIMEOUT"}
      })

      set_envs(%{
        "GRAPH_URL" => "https://graph.facebook.com/v1",
        "REQUEST_CONN_TIMEOUT" => "100"
      })

      {:ok, _} = Application.ensure_all_started(:facebook)

      assert Config.graph_url() == "https://graph.facebook.com/v1"
      assert Config.request_conn_timeout() == 100
    end

    test "fails to start when {:system, _} tuple is used but env is missing" do
      :ok = Application.stop(:facebook)

      set_config(%{
        graph_url: {:system, "GRAPH_URL"},
        request_conn_timeout: {:system, :integer, "REQUEST_CONN_TIMEOUT"}
      })

      assert {:error,
              {:facebook,
               {{:shutdown,
                 {:failed_to_start_child, Facebook.Config,
                  {%ArgumentError{
                     message:
                       "could not fetch environment variable \"GRAPH_URL\" because it is not set"
                   }, _}}},
                {Facebook, :start, [:normal, []]}}}} = Application.ensure_all_started(:facebook)
    end
  end

  defp set_config(values) do
    original_config = Application.get_all_env(:facebook)

    for {key, value} <- values do
      Application.put_env(:facebook, key, value)
    end

    on_exit(fn ->
      for {key, _value} <- values do
        Application.put_env(:facebook, key, Keyword.get(original_config, key))
      end

      {:ok, _} = Application.ensure_all_started(:facebook)
    end)
  end

  defp set_envs(envs) do
    for {key, value} <- envs do
      System.put_env(key, value)
    end

    on_exit(fn ->
      for {key, _value} <- envs do
        System.delete_env(key)
      end
    end)
  end
end
