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

-module(monad_plus).
-compile({parse_transform, do}).

-export([mzero/0, mplus/2]).
-export([mzero/1]).
-export([guard/1, msum/1, mfilter/2]).

%% MonadPlus primitives
-callback mzero() -> monad:monadic(_M, _A).
-callback mplus(monad:monadic(M, A), monad:monadic(M, A)) -> monad:monadic(M, A).

mzero() ->
    undetermined:new(fun(MPlus) -> mzero(MPlus) end).

mplus(UA, UB) ->
    undetermined:map_pair(
      fun(Module, MA, MB) ->
              Module:mplus(MA, MB)
      end, UA, UB, ?MODULE).

mzero(MPlus) ->
    monad_trans:apply_fun(mzero, [], MPlus).

%% Utility functions
-spec guard(boolean()) -> monad:monadic(_M, _A).
guard(true)  -> monad:return(ok);
guard(false) -> mzero().

-spec msum([monad:monadic(M, A)]) -> monad:monadic(M, A).
msum(List) ->
    lists:foldr(fun mplus/2, mzero(), List).

-spec mfilter(fun( (A) -> boolean() ), monad:monadic(M, A)) -> monad:monadic(M, A).
mfilter(Pred, X) ->
    do([monad || A <- X, guard(Pred(A))]).
