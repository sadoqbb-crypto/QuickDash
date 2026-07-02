(function(){
  const cfg = window.QUICKDASH_SUPABASE || {};
  let client = null;
  let lastError = "";
  let saveTimer = null;

  function configured(){
    return Boolean(cfg.url && cfg.anonKey && window.supabase);
  }

  function databaseCode(){
    return cfg.databaseCode || "QD-DEMO-0001";
  }

  function getClient(){
    if(!configured()) return null;
    if(!client) client = window.supabase.createClient(cfg.url, cfg.anonKey);
    return client;
  }

  async function pullSnapshot(){
    const db = getClient();
    if(!db) return null;
    const { data, error } = await db
      .from("app_snapshots")
      .select("payload,updated_at")
      .eq("database_code", databaseCode())
      .maybeSingle();
    if(error){ lastError = error.message; console.warn("QuickDash cloud pull failed", error); return null; }
    return data?.payload || null;
  }

  async function pushSnapshot(payload){
    const db = getClient();
    if(!db) return { ok:false, offline:true };
    const row = {
      database_code: databaseCode(),
      payload,
      updated_at: new Date().toISOString()
    };
    const { error } = await db.from("app_snapshots").upsert(row, { onConflict:"database_code" });
    if(error){ lastError = error.message; console.warn("QuickDash cloud save failed", error); return { ok:false, error:error.message }; }
    return { ok:true };
  }

  function pushSnapshotSoon(payload){
    clearTimeout(saveTimer);
    saveTimer = setTimeout(() => pushSnapshot(payload), 450);
  }

  function status(){
    return {
      configured: configured(),
      databaseCode: databaseCode(),
      lastError
    };
  }

  window.QuickDashCloud = { configured, databaseCode, pullSnapshot, pushSnapshot, pushSnapshotSoon, status };
})();
