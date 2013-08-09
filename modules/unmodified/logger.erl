%% Original Code
%% Created: 18/09/2011
%% Description: Accepts events and prints them on screen
-module(logger).

-export([start/1, stop/1]).

start(Nodes) ->
	spawn(fun() ->init(Nodes) end).

stop(Logger) ->
	Logger ! stop.

init(Nodes) ->
	loop([],Nodes).

loop(Queue,Nodes) ->
	receive
		{log, From, Time, Msg} ->
			Unordered = [{From,Time,Msg}|Queue],
			Sorted = lists:keysort(2, Unordered),
			NewQueue = print(Sorted,Nodes),
			loop(NewQueue,Nodes);
	
		stop ->
			ok
	end.

log(From, Time, Msg) ->
	io:format("log: ~w ~w ~p~n", [From, Time, Msg]).

print([{From,Time,Msg}|Rest],Nodes)->
	RestNodes=Nodes--[From],
	case existcolleagues(Rest,RestNodes) of
	true->   
		log(From,Time,Msg),
		   print(Rest,Nodes);
	false ->
		[{From,Time,Msg}|Rest]
	end.  

existcolleagues(Rest,[])->
	true;

existcolleagues(Rest,[H|T])->
	case lists:keymember(H, 1, Rest) of
		true->
			existcolleagues(Rest,T);
		false->
			false
	end.
