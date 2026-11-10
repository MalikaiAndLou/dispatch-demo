trigger CaseRouterTrigger on Case (after insert) {
    CaseRouter.route(Trigger.new);
}