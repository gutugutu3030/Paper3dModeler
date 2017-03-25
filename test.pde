void test(){
  scanImage(loadImage(dataPath("ZIP.jpg")),new HashMap<String,Object>(){
    {
      put("showDebugWindow",Boolean.TRUE);
      put("forceFreeformMode",Boolean.TRUE);
    }
  });
}
Object getTestMap(Map<String,Object> test,String str){
  if(test==null){
    return null;
  }
  return test.get(str);
}
