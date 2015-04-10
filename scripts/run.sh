#!/bin/sh

. ./service.conf

echo $$ | tee .gpid
../front/script/front daemon -l "http://*:$SERVICE_FRONT_PORT" &
../main_logic/script/main_logic daemon -l "http://*:$SERVICE_LOGIC_PORT" &
../session/script/session daemon -l "http://*:$SERVICE_SESSION_PORT" &
../backend_jobs/script/backend_jobs daemon -l "http://*:$SERVICE_JOBS_PORT" &
../backend_companies/script/backend_companies daemon -l "http://*:$SERVICE_COMPANIES_PORT" &
