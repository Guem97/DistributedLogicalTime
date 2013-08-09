%% Author: Alberto Lorente Leal, 
%% albll@kth.se
%% a.lorenteleal@gmail.com
%% Created: 18/09/2011
%% Description: TODO: Add description to worker
-module(lampworker).

-export([start/5, stop/1]).

start(Name, Logger, Seed, Sleep, Jitter) ->
	spawn(fun() -> init(Name, Logger, Seed, Sleep, Jitter) end).

stop(Worker) ->
	Worker ! stop.

init(Name, Log, Seed, Sleep, Jitter) ->
	random:seed(Seed, Seed, Seed),
	receive
		{peers, Peers} ->
			loop(Name, Log, Peers, Sleep, Jitter);
		stop ->
			ok
	end.

loop(Name, Log, Peers, Sleep, Jitter)->
	Wait = random:uniform(Sleep),
	receive
		{msg, Time, Msg} ->
			Log ! {log, Name, Time, {received, Msg}},
			loop(Name, Log, Peers, Sleep, Jitter);
		stop ->
			ok;
		Error ->
			Log ! {log, Name, time, {error, Error}}
		after Wait ->
			Selected = select(Peers),
			Time = na,
			Delay = random:uniform(Jitter),
			Message = {hello, Delay},
			Selected ! {msg, Time, Message},
			timer:sleep(Delay),
			Log ! {log, Name, Time, {sending, Message}},
			loop(Name, Log, Peers, Sleep, Jitter)
	end.

select(Peers) ->
	lists:nth(random:uniform(length(Peers)), Peers).