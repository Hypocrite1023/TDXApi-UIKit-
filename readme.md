## Task裡執行的return不會回傳
> 所以以我下面這個例子，只要進到else後就馬上return nil
```Swift
// 修正寫法
func getToken() async -> String? {
  if checkTokenAlive() { // token 還有效
      print("token from userdefault")
      return UserDefaults.standard.string(forKey: UserDefaultString.tokenKey)
  }
  else { // token 沒效,重新 get token
      
      print("get new token")
      return try? await getNewToken()
      
  }
}
// 原本的寫法
func getToken() async -> String? {
  if checkTokenAlive() { // token 還有效
      print("token from userdefault")
      return UserDefaults.standard.string(forKey: UserDefaultString.tokenKey)
  }
  else { // token 沒效,重新 get token
      Task {
        print("get new token")
        return try? await getNewToken()
      }
  }
  return nil
}
```
