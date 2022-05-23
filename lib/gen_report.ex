defmodule GenReport do
  alias GenReport.Parser

  @available_users [
    "daniele",
    "mayk",
    "giuliano",
    "cleiton",
    "jakeliny",
    "joseph",
    "danilo",
    "diego",
    "cleiton",
    "rafael",
    "vinicius"
  ]

  @avaliable_months %{
    1 => "janeiro",
    2 => "fevereiro",
    3 => "março",
    4 => "abril",
    5 => "maio",
    6 => "junho",
    7 => "julho",
    8 => "agosto",
    9 => "setembro",
    10 => "outubro",
    11 => "novembro",
    12 => "dezembro"
  }

  @avaliable_years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def build(filename) do
    result =
      filename
      |> Parser.parse_file()
      |> Enum.reduce(report_acc(), fn line, report -> gen_report(line, report) end)

    {:ok, result}
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  defp gen_report([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    new_name = String.downcase(name)
    all_hours = gen_all_hours(all_hours, new_name, hours)
    hours_per_month = gen_hours_per_month(hours_per_month, new_name, hours, month)
    hours_per_year = gen_hours_per_year(hours_per_year, new_name, hours, year)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp gen_hours_per_month(hours_per_month, name, hours, month) do
    calc_hours_month =
      hours_per_month
      |> Map.get(name)
      |> Map.update(@avaliable_months[month], 0, fn curr -> +hours end)

    %{hours_per_month | name => calc_hours_month}
  end

  defp gen_hours_per_year(hours_per_year, name, hours, year) do
    calc_hours_year =
      hours_per_year
      |> Map.update(year, 0, fn curr -> curr + hours end)
  end

  defp gen_all_hours(all_hours, name, hours) do
    Map.put(all_hours, name, all_hours[name] + hours)
  end

  defp report_acc do
    all_hours = Enum.into(@available_users, %{}, &{&1, 0})
    hours_per_month = Enum.into(@available_users, %{}, &{&1, report_acc_month()})
    hours_per_year = Enum.into(@available_users, %{}, &{&1, report_acc_years()})

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc_month do
    @avaliable_months
    |> Map.values()
    |> Enum.into(%{}, &{&1, 0})
  end

  defp report_acc_years do
    @avaliable_years
    |> Enum.into(%{}, &{&1, 0})
  end

  defp build_report(all_hours, hours_per_month, hours_per_year),
    do: %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
end
