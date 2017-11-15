%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepher@issac.local>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Jun 2017 by Chen Slepher <slepher@issac.local>
%%%-------------------------------------------------------------------
-module(reader_t_SUITE).

%% Note: This directive should only be used in test suites.
-compile(export_all).
-compile({parse_transform, do}).

-include_lib("eunit/include/eunit.hrl").
-include_lib("common_test/include/ct.hrl").
%%--------------------------------------------------------------------
%% TEST SERVER CALLBACK FUNCTIONS
%%--------------------------------------------------------------------
suite() ->
    [{timetrap,{seconds,10}}].

%%--------------------------------------------------------------------
%%
%% @doc
%% Initialization before the suite.
%%
%% Config0 = Config1 = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%% Reason = term()
%%   The reason for skipping the suite.
%%
%% Note: This function is free to add any key/value pairs to the Config
%% variable, but should NOT alter/remove any existing entries.
%%
%% @spec init_per_suite(Config) -> Config
%% @end
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    {ok, _} = application:ensure_all_started(erlando),
    Config.

%%--------------------------------------------------------------------
%% @doc
%% Cleanup after the suite.
%% Config - [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%%
%% @spec end_per_suite(Config) -> _
%% @end
%%--------------------------------------------------------------------
end_per_suite(_Config) ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% Initialization before each test case
%%
%% TestCase - atom()
%%   Name of the test case that is about to be run.
%% Config - [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%% Reason = term()
%%   The reason for skipping the test case.
%%
%% Note: This function is free to add any key/value pairs to the Config
%% variable, but should NOT alter/remove any existing entries.
%%
%% @spec init_per_testcase(TestCase, Config) -> Config
%% @end
%%--------------------------------------------------------------------
init_per_testcase(_TestCase, Config) ->
    Config.

%%--------------------------------------------------------------------
%% @doc
%% Cleanup after each test case
%%
%% TestCase = atom()
%%   Name of the test case that is finished.
%% Config = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%%
%% @spec end_per_testcase(TestCase, Config) -> _
%% @end
%%--------------------------------------------------------------------
end_per_testcase(_TestCase, _Config) ->
    ok.

%%--------------------------------------------------------------------
%% @doc
%% Returns a description of the test suite when
%% Clause == doc, and a test specification (list
%% of the conf and test cases in the suite) when
%% Clause == suite.
%% Returns a list of all test cases in this test suite
%%
%% Clause = doc | suite
%%   Indicates expected return value.
%% Descr = [string()] | []
%%   String that describes the test suite.
%% Spec = [TestCase]
%%   A test specification.
%% TestCase = ConfCase | atom()
%%   Configuration case, or the name of a test case function.
%% ConfCase = {conf,Init,Spec,End} |
%%            {conf,Properties,Init,Spec,End}
%% Init = End = {Mod,Func} | Func
%%   Initialization and cleanup function.
%% Mod = Func = atom()
%% Properties = [parallel | sequence | Shuffle | {RepeatType,N}]
%%   Execution properties of the test cases (may be combined).
%% Shuffle = shuffle | {shuffle,Seed}
%%   To get cases executed in random order.
%% Seed = {integer(),integer(),integer()}
%% RepeatType = repeat | repeat_until_all_ok | repeat_until_all_fail |
%%              repeat_until_any_ok | repeat_until_any_fail
%%   To get execution of cases repeated.
%% N = integer() | forever
%% Reason = term()
%%   The reason for skipping the test suite.
%%
%% @spec all(Clause) -> TestCases
%% @end
%%--------------------------------------------------------------------
all() -> 
    [test_reader_t_ask, test_monad_laws, test_monad_fail, test_local, test_monad_lift,
     test_reader, test_monad_state0, test_monad_state1, test_monad_state2].


%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% @doc
%%  Test case function. Returns a description of the test
%%  case (doc), then returns a test specification (suite),
%%  or performs the actual test (Config).
%%
%% Arg = doc | suite | Config
%%   Indicates expected behaviour and return value.
%% Config = [tuple()]
%%   A list of key/value pairs, holding the test case configuration.
%% Descr = [string()] | []
%%   String that describes the test case.
%% Spec = [tuple()] | []
%%   A test specification, see all/1.
%% Reason = term()
%%   The reason for skipping the test case.
%%
%% @spec TestCase(Arg) -> Descr | Spec | ok | exit() | {skip,Reason}
%% @end
%%--------------------------------------------------------------------
test_reader_t_ask() ->
    [{doc, "Test reader_t"}].

test_reader_t_ask(_Config) ->
    M0 = 
        do([reader_m ||
               Local <- monad_reader:ask({reader_t, identity}),
               return({Local, world})
           ]),
    ?assertEqual({hello, world}, reader_m:run(M0, hello)).


test_monad_laws(_Config) ->
    Monad = reader_t:new(either),

    F = fun(A) -> do([Monad || 
                         Value <- reader_t:ask(),
                         return(Value + 3 + A)
                     ])
        end,

    G = fun(A) -> do([ Monad ||
                         Value <- reader_t:ask(),
                         return(Value * 7 + A)
                     ])
        end,
    M1 = do([Monad ||
                Value <- return(2),
                F(Value)
            ]),

    M2 = F(2),
    
    ?assertEqual({right, 9}, either:run(reader_t:run(M1, 4))),
    ?assertEqual({right, 9}, either:run(reader_t:run(M2, 4))),
    
    M3 = do([Monad ||
               Value <- reader_t:ask(),
               return(Value + 4)]),
                  
    M4 = do([Monad ||
                Value <- M3,
                return(Value)]),
    ?assertEqual({right, 7}, either:run(reader_t:run(M3, 3))),
    ?assertEqual({right, 7}, either:run(reader_t:run(M4, 3))),
    
    M5 = do([Monad || 
                Y <- do([Monad || X <- M3, F(X) ]),
                G(Y)
            ]),
    M6 = do([Monad ||
                X <- M3,
                do([Monad ||
                       Y <- F(X),
                       G(Y)])
            ]),
    M7 = do([Monad ||
                X <- M3,
                Y <- F(X),
                G(Y)
            ]),
    
    ?assertEqual({right, 97}, either:run(reader_t:run(M5, 10))),
    ?assertEqual({right, 97}, either:run(reader_t:run(M6, 10))),
    ?assertEqual({right, 97}, either:run(reader_t:run(M7, 10))).

test_monad_fail(_Config) ->
    Monad = reader_t:new(either),
    M0 = do([Monad ||
                Value <- reader_t:ask(),
                fail(Value + 3)
            ]),
    
    ?assertEqual({left, 13}, either:run(reader_t:run(M0, 10))).

test_monad_lift(_Config) ->
    Monad = reader_t:new(either),
    M0 = do([Monad ||
                X <- reader_t:ask(),
                Y <- reader_t:lift(either:return(10)),
                return(X * Y)
            ]),
    
    ?assertEqual({right, 60}, either:run(reader_t:run(M0, 6))).

test_local(_Config) ->
    Monad = reader_t:new(either),
    M0 = do([Monad ||
                X <- reader_t:ask(),
                Y <- reader_t:lift(either:return(10)),
                return(X * Y)
            ]),
    
    M1 = reader_t:local(fun(X) -> X * 2 end, M0),
    ?assertEqual({right, 120}, either:run(reader_t:run(M1, 6))).

test_reader(_Config) ->
    Monad0 = reader_t:new(identity),
    M0 = do([Monad0 ||
                Value <- reader_t:ask(),
                return(length(Value))
            ]),
    M1 = reader_t:reader(fun(R) -> identity:run(reader_t:run(M0, R)) end),

    ?assertEqual({right, 3}, either:run(reader_t:run(M1, [1,2,3]))).

test_monad_state0(_Config) ->
    M0 = do([monad ||
                monad_state:get()
            ]),
    ?assertEqual(2, state_m:eval(reader_t:run(M0, 3), 2)).

test_monad_state1(_Config) ->
    Monad = reader_t:new(state_t:new(identity)),
    M0 = do([Monad ||
                A <- monad_reader:ask(),
                S <- monad_state:get(),
                monad_state:put(S + A)
            ]),

    ?assertEqual(4, identity:run(state_t:exec(reader_t:run(M0, 3), 1))).

test_monad_state2(_Config) ->
    M0 = do([monad ||
                A <- monad_reader:ask(),
                S <- monad_state:get(),
                monad_state:put(S + A)
            ]),
    ?assertEqual(4, identity:run(state_t:exec(reader_t:run(M0, 3), 1))).
