# 사기 탐지 01
SELECT
  System.Timestamp as WindowEnd, SwitchNum, COUNT(*) as CallCount
INTO
  [output]
FROM
  [input] TIMESTAMP BY CallRecTime
GROUP BY TUMBLINGWINDOW(s, 5), SwitchNum

# 사기 탐지 02
SELECT  System.Timestamp as Time,
  CS1.CallingIMSI,
  CS1.CallingNum as CallingNum1,
  CS2.CallingNum as CallingNum2,
  CS1.SwitchNum as Switch1,
  CS2.SwitchNum as Switch2
INTO
  [output]
FROM
  [input] CS1 TIMESTAMP BY CallRecTime
  JOIN [input] CS2 TIMESTAMP BY CallRecTime
    ON CS1.CallingIMSI = CS2.CallingIMSI
    AND DATEDIFF(ss, CS1, CS2) BETWEEN 1 AND 5
WHERE CS1.SwitchNum != CS2.SwitchNum
