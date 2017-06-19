%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License
%% at http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and
%% limitations under the License.

-module(monad_state_trans).

-callback get(M) -> monad:monadic(M, _S).
-callback put(_S, M)  -> monad:monadic(M, ok).
-callback state(fun((S) -> {A, S}), M) -> monad:monadic(M, A).
