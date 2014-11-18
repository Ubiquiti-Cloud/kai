-module(kai_folsom).
-author('Adam Rutkowski <hq@mtod.org>').

-export([init_static_metrics/0]).

-export([name_rest_ok/1,
         name_rest_nok/1,
         name_rest_ok_lat/1,
         name_rest_nok_lat/1,
         name_rest_ok_size/1]).

-export([name_writes/0,
         name_ping/1]).

-export([begin_rest_ok_lat/1,
         begin_rest_nok_lat/1]).

-export([notify_lat/1,
         notify_spiral/1,
         notify_hist/2]).

-define(REST   , "kai.rest.").
-define(TELNET , "kai.telnet.").

-define(REST_ENDPOINTS, [query_metrics,
                         query_metrics_tags,
                         delete_datapoints,
                         delete_metric,
                         list_metric_names,
                         list_tag_values]).

init_static_metrics() ->
    _ = [begin
         N1 = name_rest_ok(Call),
         N2 = name_rest_nok(Call),
         N3 = name_rest_ok_lat(Call),
         N4 = name_rest_nok_lat(Call),
         N5 = name_rest_ok_size(Call),
         lager:debug("Initializing spiral ~s", [N1]),
         ok = folsom_metrics:new_spiral(N1),
         lager:debug("Initializing spiral ~s", [N2]),
         ok = folsom_metrics:new_spiral(N2),
         lager:debug("Initializing histogram ~s", [N3]),
         ok = folsom_metrics:new_histogram(N3),
         lager:debug("Initializing histogram ~s", [N4]),
         ok = folsom_metrics:new_histogram(N4),
         lager:debug("Initializing histogram ~s", [N5]),
         ok = folsom_metrics:new_histogram(N5)
     end || Call <- ?REST_ENDPOINTS],
    N5 = name_writes(),
    ok = folsom_metrics:new_spiral(N5),
    N6 = name_ping(pang),
    N7 = name_ping(pong),
    ok = folsom_metrics:new_spiral(N6),
    ok = folsom_metrics:new_spiral(N7).


begin_rest_ok_lat(Call) ->
    Name = name_rest_ok_lat(Call),
    folsom_metrics:histogram_timed_begin(Name).

begin_rest_nok_lat(Call) ->
    Name = name_rest_nok_lat(Call),
    folsom_metrics:histogram_timed_begin(Name).

notify_lat(LatMetric) ->
    ok = folsom_metrics:histogram_timed_notify(LatMetric).

notify_spiral(Name) ->
    ok = folsom_metrics:notify({Name, 1}).

notify_hist(Name, Size) ->
    ok = folsom_metrics:notify({Name, Size}).

name_rest_ok(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".OK">>.

name_rest_nok(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".NOK">>.

name_rest_ok_lat(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".OK.latency">>.

name_rest_nok_lat(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".NOK.latency">>.

name_rest_ok_size(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".OK.size">>.

name_writes() ->
    <<?TELNET, "writes">>.

name_ping(pong) ->
    <<?TELNET, "ping.pong">>;
name_ping(pang) ->
    <<?TELNET, "ping.pang">>.

bin(A) when is_atom(A) ->
    erlang:atom_to_binary(A, latin1).
