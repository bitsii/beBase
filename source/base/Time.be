/*
 * Copyright (c) 2006-2023, the Brace Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

import Time:Interval;

emit(c) {
"""
#ifdef BENM_ISNIX
#include <sys/time.h>
#endif
#ifdef BENM_ISWIN
#include <sys/time.h>
#endif
"""
}

emit(cs) {
"""
using System;
using System.Threading;
"""
}
 
class Time:Sleep {

    create() self { }
   
   default() self {
      
   }
   
   sleep(Interval interval) {
      if (def(interval)) {
         Int secs = interval.secs;
         Int millis = interval.millis;
         if (def(secs) && def(millis)) {
            Int sleepMillis = (secs * 1000) + millis;
            sleepMilliseconds(sleepMillis);
         }
      }
   }
   
   sleepSeconds(Int secs) {
      return(sleepMilliseconds(secs * 1000));
   }
   
   sleepMilliseconds(Int msecs) {
      emit(c) {
      """
/*-attr- -dec-*/
long bevl_long;
void** bevl_msecs;
      """
      }
      emit(c) {
      """
      bevl_msecs = $msecs&*;
      bevl_long = (long) *((BEINT*) (bevl_msecs + bercps));
#ifdef BENM_ISNIX
      bevl_long = bevl_long * 1000;
      usleep(bevl_long);
#endif
#ifdef BENM_ISWIN
      Sleep(bevl_long);
#endif
      """
      }
      emit(jv) {
      """
      Thread.sleep(beva_msecs.bevi_int);
      """
      }
      emit(cs) {
      """
      Thread.Sleep(beva_msecs.bevi_int);
      """
      }
      emit(cc) {
      """
      BECS_Runtime::bemg_enterBlocking();
      std::this_thread::sleep_for(std::chrono::milliseconds(beq->beva_msecs->bevi_int));
      BECS_Runtime::bemg_exitBlocking();
      """
      }
      ifNotEmit(apwk) {
        emit(js) {
        """
        //this is bad, don't use it, replace with npm when available or something better
        //?set timeout (node too?)
        var start = new Date().getTime();
        while (1) {
          if ((new Date().getTime() - start) > beva_msecs.bevi_int){
            break;
          }
        }
        """
        }
      }
      ifEmit(apwk) {
        String jspw = "sleepMillis:" + msecs
        emit(js) {
        """
        var jsres = prompt(bevl_jspw.bems_toJsString());
        """
        }
      }
   }
   
}

//an unanchored period of time
class Interval {

    emit(cs) {
    """
    public static readonly DateTime epochStart = new DateTime
    (1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
    """
    }

    //create an interval which is the time since the epoch (Jan 1, 1970, utc) to now
    now() self {
      emit(c) {
      """
        /*-attr- -dec-*/
        struct timeval bevl_start;
        """
        }
        secs = Int.new();
        millis = Int.new();
        emit(c) {
        """
        gettimeofday(&bevl_start, NULL);
        *((BEINT*) ($secs&* + bercps)) = (BEINT) bevl_start.tv_sec;
        *((BEINT*) ($millis&* + bercps)) = (BEINT) (bevl_start.tv_usec / 1000L);
        """
        }
        emit(jv) {
            """
            long ctm = System.currentTimeMillis();
            bevp_secs.bevi_int = (int) (ctm / 1000);
            bevp_millis.bevi_int = (int) (ctm % 1000);
            """
        }
        emit(cs) {
        """
        long ctm = (long) (DateTime.UtcNow - epochStart).TotalMilliseconds;
        bevp_secs.bevi_int = (int) (ctm / 1000);
        bevp_millis.bevi_int = (int) (ctm % 1000);
        """
        }
        emit(cc) {
        """
        unsigned long milliseconds_since_epoch =
          std::chrono::system_clock::now().time_since_epoch() / 
          std::chrono::milliseconds(1);
        bevp_secs->bevi_int = (int32_t) (milliseconds_since_epoch / 1000);
        bevp_millis->bevi_int = (int32_t) (milliseconds_since_epoch % 1000);
        """
        }
        emit(js) {
        """
        var d = new Date();
        var ctm = d.getTime(); 
        this.bevp_secs.bevi_int = ~~(ctm / 1000);
        this.bevp_millis.bevi_int = (ctm % 1000);
        """
        }
    }
    
   new() self {
      //Stored as seconds and millis within the second (abs < 1000)
      //for times, xIny is the x within y (< the number of x's in y) (x % xes in y) 
      //just x is the total interval in x units (to it's level of granularity)
      fields {
         Int secs = 0;
         Int millis = 0;
      }
      
   }
   
   new(Int _secs, Int _millis) self {
      secs = _secs;
      millis = _millis;
      carryMillis();
   }
   
   copy() self {
      return(Interval.new(secs, millis));
   }
   
   secondInMinuteGet() Int {
        return(secs % 60);
   }
   
   millisecondInSecondGet() Int {
      return(millis);
   }
   
   minutesGet() Int {
      return(secs / 60);
   }
   
   secondsGet() Int {
      return(secs);
   }
   
   secondsSet(Int _secs) self {
      secs = _secs;
   }
   
   millisecondsGet() Int {
      return(millis);
   }
   
   millisecondsSet(Int _millis) self {
      millis = _millis;
      carryMillis();
   }
   
   addHours(Int hours) self {
      secs = secs + (3600 * hours);
   }
   
   addDays(Int days) self {
      secs = secs + (86400 * days);
   }
   
   subtractHours(Int hours) self {
      secs = secs - (3600 * hours);
   }
   
   subtractDays(Int days) self {
      secs = secs - (86400 * days);
   }
   
   
   addSeconds(Int _secs) self {
      secs = secs + _secs;
   }
   
   addMilliseconds(Int _millis) {
      millis = millis + _millis;
      carryMillis();
   }
   
   carryMillis() {
      Int mmod = millis % 1000;
      if (mmod != millis) {
        secs = secs + (millis / 1000);
        millis = mmod;
      }
      if (millis < 0 && secs > 0) { //1 sec -200 millis == 0 sec 800 millis
        secs = secs - 1; 
        millis = 1000 + millis;
      } elseIf (millis > 0 && secs < 0) { //-2 sec 50 millis == -1 sec -950 millis
        secs = secs + 1;
        millis = (0 - 1000) + millis;
      }
   }
   
   subtractSeconds(Int _secs) self {
      secs = secs - _secs;
   }
   
   subtractMilliseconds(Int _millis) self {
      millis = millis - _millis;
      carryMillis();
   }
   
   add(Interval other) Interval {
      Int _secs = secs + other.secs;
      Int _millis = millis + other.millis;
      Interval res = Interval.new(_secs, _millis);
      res.carryMillis();
      return(res);
   }
   
   subtract(Interval other) Interval {
      Int _secs = secs - other.secs;
      Int _millis = millis - other.millis;
      Interval res = Interval.new(_secs, _millis);
      res.carryMillis();
      return(res);
   }
   
   greater(Interval other) Bool {
      if ((secs > other.secs) || (secs == other.secs && millis > other.millis)) {
         return(true);
      }
      return(false);
   }
   
   lesser(Interval other) Bool {
      if ((secs < other.secs) || (secs == other.secs && millis < other.millis)) {
         return(true);
      }
      return(false);
   }
   
   greaterEquals(Interval other) Bool {
      if ((secs >= other.secs) || (secs == other.secs && millis >= other.millis)) {
         return(true);
      }
      return(false);
   }
   
   lesserEquals(Interval other) Bool {
      if ((secs <= other.secs) || (secs == other.secs && millis <= other.millis)) {
         return(true);
      }
      return(false);
   }
   
   equals(other) Bool {
      if (undef(other)) { return(false); }
      if  (System:Classes.sameClass(self, other) && secs == other.secs && millis == other.millis) {
         return(true);
      }
      return(false);
   }
   
   notEquals(other) Bool {
      if (undef(other)) { return(true); }
      if (System:Classes.sameClass(self, other)! || secs != other.secs || millis != other.millis) {
         return(true);
      }
      return(false);
   }
   
   // True if absolute difference between self and other is exactly one hour
   offByHour(Interval other) Bool {
      if (undef(other)) { return(false); }
      if (millis == other.millis) {
         if ((secs - other.secs).abs() == 3600) {
            return(true);
         }
      }
      return(false);
   }
   
   toStringMinutes() String {
      return(self.minutes.toString() + " minutes, " + self.secondInMinute + " seconds and " + millis + " milliseconds");
   }
   
   toShortString() String {
     return(secs.toString() + ":" + millis.toString());
   }
   
   toString() String {
      return(secs.toString() + " seconds and " + millis + " milliseconds");
   }
   
}

class Time:Stamp(Interval) {

   emit(jv) {
   """
   java.util.TimeZone bevi_zone = java.util.TimeZone.getTimeZone("Etc/UTC");
   """
   }
   
   new() {
     self.now();
   }
   
   copy() self {
      var cp = Time:Stamp.new(secs, millis);
      cp.localZone = localZone;
   }
   
   localZoneSet(Bool _localZone) {
     if (undef(localZone)) {
       localZone = false;
     }
     fields {
       Bool localZone = _localZone;
     }
     if (localZone) {
       emit(jv) {
       """
         bevi_zone = java.util.TimeZone.getDefault();
       """
       }
     }
   }
   
   localZoneGet() Bool {
     if (undef(localZone)) { return(false); }
     return(localZone);
   }
   
   yearGet() String {
     String rval;
     emit(jv) {
     """
       
       long ms = (long) bevp_secs.bevi_int;
       ms = ms * 1000;
       ms = ms + ((long) bevp_millis.bevi_int);
       
       java.util.Date date = new java.util.Date(ms);
       java.text.DateFormat format = new java.text.SimpleDateFormat("yyyy");
       format.setTimeZone(bevi_zone);
       String formatted = format.format(date);
       bevl_rval = new $class/Text:String$(formatted);
       
     """
     }
     return(rval);
   }
   
   monthGet() String {
     String rval;
     emit(jv) {
     """
       
       long ms = (long) bevp_secs.bevi_int;
       ms = ms * 1000;
       ms = ms + ((long) bevp_millis.bevi_int);
       
       java.util.Date date = new java.util.Date(ms);
       java.text.DateFormat format = new java.text.SimpleDateFormat("MM");
       format.setTimeZone(bevi_zone);
       String formatted = format.format(date);
       bevl_rval = new $class/Text:String$(formatted);
       
     """
     }
     return(rval);
   }
   
   dayGet() String {
     String rval;
     emit(jv) {
     """
       
       long ms = (long) bevp_secs.bevi_int;
       ms = ms * 1000;
       ms = ms + ((long) bevp_millis.bevi_int);
       
       java.util.Date date = new java.util.Date(ms);
       java.text.DateFormat format = new java.text.SimpleDateFormat("dd");
       format.setTimeZone(bevi_zone);
       String formatted = format.format(date);
       bevl_rval = new $class/Text:String$(formatted);
       
     """
     }
     return(rval);
   }
   
   hourGet() String {
     String rval;
     emit(jv) {
     """
       
       long ms = (long) bevp_secs.bevi_int;
       ms = ms * 1000;
       ms = ms + ((long) bevp_millis.bevi_int);
       
       java.util.Date date = new java.util.Date(ms);
       java.text.DateFormat format = new java.text.SimpleDateFormat("HH");
       format.setTimeZone(bevi_zone);
       String formatted = format.format(date);
       bevl_rval = new $class/Text:String$(formatted);
       
     """
     }
     return(rval);
   }
   
   minuteGet() String {
     String rval;
     emit(jv) {
     """
       
       long ms = (long) bevp_secs.bevi_int;
       ms = ms * 1000;
       ms = ms + ((long) bevp_millis.bevi_int);
       
       java.util.Date date = new java.util.Date(ms);
       java.text.DateFormat format = new java.text.SimpleDateFormat("mm");
       format.setTimeZone(bevi_zone);
       String formatted = format.format(date);
       bevl_rval = new $class/Text:String$(formatted);
       
     """
     }
     return(rval);
   }
   
   secondGet() String {
     String rval;
     emit(jv) {
     """
       
       long ms = (long) bevp_secs.bevi_int;
       ms = ms * 1000;
       ms = ms + ((long) bevp_millis.bevi_int);
       
       java.util.Date date = new java.util.Date(ms);
       java.text.DateFormat format = new java.text.SimpleDateFormat("ss");
       format.setTimeZone(bevi_zone);
       String formatted = format.format(date);
       bevl_rval = new $class/Text:String$(formatted);
       
     """
     }
     return(rval);
   }
   
   millisecondGet() String {
     return(millis.toString());
   }
   
   //("dd/MM/yyyy HH:mm:ss")
   
}


