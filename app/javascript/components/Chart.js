import React, { useEffect, useState } from "react";
import styles from "./Chart.module.css";
import ax from "packs/axios";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ReferenceLine,
} from "recharts";

export default function Charts({ chartData }) {
  const lineChartData = chartData.data;
  const teamData = chartData.teams;
  const matchData = chartData.matches;

  function customToolTip(props) {
    return (
      <div className={styles.toolTip}>
        <div className={styles.toolTipTitle}>{props.label}</div>
        <ul className={styles.matches}>
          {matchData
            .filter((d) => d.date == props.label)
            .map((datum) => {
              return renderMatch(datum);
            })}
        </ul>
      </div>
    );
  }

  function renderEloChange(changeAmount) {
    let changeStyle, formattedAmount;
    if (changeAmount < 0) {
      changeStyle = styles.negativeChange;
      formattedAmount = changeAmount.toString();
    } else {
      changeStyle = styles.positiveChange;
      formattedAmount = "+ " + changeAmount.toString();
    }

    return <div className={changeStyle}>{formattedAmount}</div>;
  }

  function renderMatch(match) {
    let score = `${match.opponent_1.score} - ${match.opponent_2.score}`;

    return (
      <li className={styles.match}>
        <div className={styles.opponent}>
          <div
            className={styles.opponentAcronym}
            style={{ borderBottom: `2px solid ${match.opponent_1.color}` }}
          >
            {match.opponent_1.acronym}
          </div>
          <div className={styles.opponentEloData}>
            <div className={styles.opponentElo}>{match.opponent_1.elo}</div>
            {renderEloChange(match.opponent_1.elo_change)}
          </div>
        </div>
        <div className={styles.matchResult}>{score}</div>
        <div className={styles.opponent}>
          <div
            className={styles.opponentAcronym}
            style={{ borderBottom: `2px solid ${match.opponent_2.color}` }}
          >
            {match.opponent_2.acronym}
          </div>
          <div className={styles.opponentEloData}>
            <div className={styles.opponentElo}>{match.opponent_2.elo}</div>
            {renderEloChange(match.opponent_2.elo_change)}
          </div>
        </div>
      </li>
    );
  }

  return (
    <>
      <LineChart width={1200} height={800} data={lineChartData}>
        <CartesianGrid />
        <XAxis dataKey="name" padding={{ left: 30, right: 30 }} />
        <YAxis type="number" domain={["dataMin - 50", "dataMax + 50"]} />
        <Legend />
        <Tooltip content={customToolTip} />
        {teamData.map((team) => {
          return (
            <Line
              key={team.id}
              type="monotone"
              strokeWidth={2}
              dataKey={team.acronym}
              stroke={team.color}
            />
          );
        })}
      </LineChart>
    </>
  );
}
