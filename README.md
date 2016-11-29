
# MHPlayer
一句代码集成视频播放器 `Swift 3.0`；
本播放器是根据`AVPlayer`进行封装的；


## 主要功能：
* 1.一句代码就能调用播放<br></br>
* 2.支持开始/暂停<br></br>
* 3.支持放大/缩小<br></br>
* 4.支持随屏幕旋转<br></br>
* 5.支持拖拽进度<br></br>
* 6.时间显示<br></br>
* 7.左边上下滑调节音量<br></br>
* 8.右边上下滑调节亮度<br></br>
* 9.左右滑调节播放进度<br></br>* 10.播放屏幕保持常亮<br></br>* 11.双击播放/暂停<br></br>

## How To Use?
```Swift
mhPlayer = MHAVPlayerSDK(frame: CGRect(x: 0, y: 40, width: view.frame.size.width, height: view.frame.size.width / 2))
        mhPlayer?.mhPlayerURL = "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"
        mhPlayer?.mhPlayerTitle = "MHPlayer"
        mhPlayer?.mhAutoOrient = true
        mhPlayer?.MHAVPlayerSDKDelegate = self
        view.addSubview(mhPlayer!)
```
##Tips:
  * 欢迎大家使用，有问题的话可以加我QQ1156154406,或者提Issues都可以，我会及时处理，最后别忘了给个star哈~
