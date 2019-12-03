%%%-------------------------------------------------------------------
%% @doc ospid4e public API
%% @end
%%%-------------------------------------------------------------------

-module(ospid4e_app).

-behaviour(application).

-ifdef(TEST).
-compile(export_all).
-include_lib("kernel/include/file.hrl").
-include_lib("eunit/include/eunit.hrl").
-endif.

%% Application callbacks
-export([start/2, stop/1]).

-define(CFG_FILE, pidfile).
-define(DEFAULT_FILE, "/tmp/ospid4e.pid").

-record(state, {pidfile}).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    error_logger:info_msg("ospid4e started."),
    %% probably not needed: ospid4e_sup:start_link()
    File = get_pidfile(),
    OsPid = os:getpid(),
    case file:write_file(File, OsPid) of
        ok ->
            error_logger:info_msg("PidFile ~p created: ~p",[File, OsPid]),
            {ok, self(), #state{pidfile = File}};
        {error, Reason} ->
            error_logger:error_msg("ospid4e error: ~p", [Reason]),
            {ok, self(), #state{pidfile = error}}
    end
    .

%%--------------------------------------------------------------------

stop(#state{pidfile = error} = _State) ->
    error_logger:info_msg("No PidFile to delete."),
    ok;
stop(#state{pidfile = PidFile} = _State) ->
    ok = file:delete(PidFile),
    error_logger:info_msg("PidFile ~p deleted.", [PidFile]),
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

get_pidfile() ->
    case application:get_env(ospid4e, ?CFG_FILE) of
        undefined ->
            ?DEFAULT_FILE;
        {ok, File} ->
            File
    end.


%%====================================================================
%% TESTs
%%====================================================================

-ifdef(TEST).

start_stop_test() ->
    ?assertEqual({error, enoent}, file:read_file_info(?DEFAULT_FILE)),

    {ok,_,_} = start(one, two),
    {ok, FI1} = file:read_file_info(?DEFAULT_FILE),
    ok = stop(#state{pidfile = error}),
    {ok, FI2} = file:read_file_info(?DEFAULT_FILE),
    ok = stop(#state{pidfile = ?DEFAULT_FILE}),

    ?assert(0 < FI1#file_info.size),
    ?assert(0 < FI2#file_info.size),
    ?assert(FI1#file_info.size == FI2#file_info.size),
    ?assertEqual({error, enoent}, file:read_file_info(?DEFAULT_FILE)),
    ok.

-endif.

%% --- end of file ---

