use worker::{self, ScheduleContext, Env, ScheduledEvent, Context, Request, Response, Error, event, console_log};

#[event(scheduled)]
pub async fn handle_scheduled_event(_event: ScheduledEvent, _env: Env, _ctx: ScheduleContext) -> () {
    console_log!("Scheduled event")
}

#[event(fetch)]
pub async fn handle_fetch_event (_req: Request, _env: Env, _ctx: Context) -> Result<Response, Error> {
    Response::ok("OK")
}
