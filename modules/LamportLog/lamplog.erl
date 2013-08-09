%% Author: Alberto Lorente Leal, 
%% albll@kth.se
%% a.lorenteleal@gmail.com
%% Created: 18/09/2011
%% Description: TODO: Add description to logger
-module(lamplog).

-export([start/1, stop/1]).

start(Nodes) ->
	spawn(fun() ->init(Nodes) end).

stop(Logger) ->
	Logger ! stop.

init(_) ->
	loop().

loop() ->
	receive
		{log, From, Time, Msg} ->
			log(From, Time, Msg),
			loop();
	
		stop ->
			ok
	end.

log(From, Time, Msg) ->
	io:format("log: ~w ~w ~p~n", [From, Time, Msg]).