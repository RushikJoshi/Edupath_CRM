/// Used by LeadBloc to decide if lead should be converted to deal (e.g. status = Won / Closed Won).
bool isLeadStageFinal(String stage) {
  final s = stage.trim().toLowerCase();
  return s == 'won' || s == 'closed won' || s == 'lost';
}

/// True when stage means "won" (lead should auto-convert to deal).
bool isLeadStageWon(String stage) {
  final s = stage.trim().toLowerCase();
  return s == 'won' || s == 'closed won';
}
