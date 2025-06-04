-module(flight_path).
-export([start/0,
        loop/1,
        readlines/1,
        get_all_lines/2,
        prep_graf/2]).

readlines(FileName) ->
    {ok, Device} = file:open(FileName, [read]),
    get_all_lines(Device, []).

get_all_lines(Device, Accum) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Accum;
        Line -> get_all_lines(Device, Accum ++ [Line])
    end.

prep_graf(G,[]) -> [];
prep_graf(G,L) ->
        H = hd(L),
        Tl = string:tokens( H,","),
        %% io:format("~p~p~n",[hd(Tl),hd(tl(Tl))]),
        digraph:add_vertex(G,hd(Tl),hd(Tl)),
        digraph:add_vertex(G,hd(tl(Tl)),hd(tl(Tl))),
        digraph:add_edge(G,hd(Tl),hd(tl(Tl))),
        prep_graf(G,tl(L)).

start() ->
        Lines = readlines("C:\\Users\\public\\flights-airport.csv"),

        G = digraph:new(),
        
        prep_graf(G,Lines),

        P = spawn(flight_path,loop,[G]),
        {G,P}.

loop(G)->
        receive 
                {Client,v} ->
                        digraph:edges(G);
                {Client,e} ->
                        digraph:vertices(G);
                {Client,V1,V2} ->
                        Client ! {digraph:get_short_path(G,V1,V2)}, 
                        digraph:get_short_path(G,V1,V2)
        end,
        loop(G).

        