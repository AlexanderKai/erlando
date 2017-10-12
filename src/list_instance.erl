%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.
%%
%% The Original Code is Erlando.
%%
%% The Initial Developer of the Original Code is VMware, Inc.
%% Copyright (c) 2011-2013 VMware, Inc.  All rights reserved.
%%

%% List Monad. Mainly just for fun! As normal, this is depth first.

-module(list_instance).

-behaviour(functor).
-behaviour(monad).
-behaviour(traversable).
-behaviour(monad_plus).

-export([fmap/2, '>>='/2, return/1, fail/1]).
-export([traverse/2]).

-export([mzero/0, mplus/2]).


traverse(A_FB, [H|T]) ->
    applicative:ap(functor:fmap(fun(A, B) -> [A|B] end, A_FB(H)), traverse(A_FB, T)),
    [A_FB(H) | traverse(A_FB, T)];
traverse(_A_FB, []) ->
    applicative:pure([]).


fmap(F, Xs) ->
    [F(X) || X <- Xs].

%% Note that using a list comprehension is (obviously) cheating, but
%% it's easier to read. The "real" implementation is also included for
%% completeness.


-spec '>>='([A], fun( (A) -> [B] )) -> [B].
'>>='(X, Fun) -> lists:append([Fun(E) || E <- X]).
%%               lists:foldr(fun (E, Acc) -> Fun(E) ++ Acc end, [], X).

-spec return(A) -> [A].
return(X) -> [X].


-spec fail(any()) -> [_A].
fail(_E) -> [].


-spec mzero() -> [_A].
mzero() -> [].


-spec mplus([A], [A]) -> [A].
mplus(X, Y) ->
    lists:append(X, Y).
