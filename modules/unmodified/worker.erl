%% Original Code
%% Created: 18/09/2011
%% Description: Sends messages to the peers to be shown on screen
-module(worker).

-export([start/5, stop/1]).

start(Name, Logger, Seed, Sleep, Jitter) ->
	spawn(fun() -> init(Name, Logger, Seed, Sleep, Jitter) end).

stop(Worker) ->
	Worker ! stop.

init(Name, Log, Seed, Sleep, Jitter) ->
	random:seed(Seed, Seed, Seed),
	receive
		{peers, Peers} ->
			loop(Name, Log, Peers, Sleep, Jitter, 0);
		stop ->
			ok
	end.

loop(Name, Log, Peers, Sleep, Jitter, Counter)->
	Wait = random:uniform(Sleep),
	receive
		{msg, Time, Msg} ->
			if Time > Counter ->
				Log ! {log, Name, Time, {received, Msg}},
				loop(Name, Log, Peers, Sleep, Jitter,Time+1);
			true->
				Log ! {log, Name, Time, {received, Msg}},
				loop(Name, Log, Peers, Sleep, Jitter,Counter+1)
			end;
		stop ->
			ok;
		Error ->
			Log ! {log, Name, time, {error, Error}}
		after Wait ->
			Selected = select(Peers),
			Time = Counter,
			Delay = random:uniform(Jitter),
			Message = {hello, Delay},
			Selected ! {msg, Time, Message},
			timer:sleep(Delay),
			Log ! {log, Name, Time, {sending, Message}},
			loop(Name, Log, Peers, Sleep, Jitter, Time)
	end.

select(Peers) ->
	lists:nth(random:uniform(length(Peers)), Peers).