package com.captain.bigdata.taichi.demo.app

import com.captain.bigdata.taichi.TaichiApp

/**
  * DemoTestUDF
  *
  * @author <a href=mailto:captain_cc_2008@163.com>CaptainDP</a>
  * @date 2018/2/1 16:26
  * @func
  */
object DemoTestUDF {

  def main(args: Array[String]): Unit = {

    val args2 = Array[String]("-d", "20190101", "-cf", "./conf/test_udf.json")
    TaichiApp.main(args2)

  }


}
