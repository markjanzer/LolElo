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

  const [selectedDate, setSeletedDate] = useState(
    matchData[matchData.length - 1].date
  );

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
    let score = `${match.opponent_1_score} - ${match.opponent_2_score}`;

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
            <div className={styles.opponentElo}>{match.opponent_1_elo}</div>
            {renderEloChange(match.opponent_1_elo_change)}
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
            <div className={styles.opponentElo}>{match.opponent_2_elo}</div>
            {renderEloChange(match.opponent_2_elo_change)}
          </div>
        </div>
      </li>
    );
  }

  function renderChart() {
    return (
      <LineChart
        width={1200}
        height={800}
        data={lineChartData}
        onClick={(chart) => setSeletedDate(chart.activeLabel)}
      >
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
    );
  }

  function renderList() {
    const dateData = lineChartData.filter((d) => d.name === selectedDate)[0];
    const formattedDateData = teamData.reduce((result, team) => {
      const datum = {
        acronym: team.acronym,
        elo: dateData[team.acronym],
        color: team.color,
      };
      result.push(datum);
      return result;
    }, []);
    const sortedFormattedDateData = formattedDateData.sort(
      (a, b) => b.elo - a.elo
    );

    return (
      <>
        <h2>{selectedDate}</h2>
        <ul>
          {sortedFormattedDateData.map((datum) => {
            return (
              <li key={datum.acronym}>
                {datum.acronym}: {datum.elo}
              </li>
            );
          })}
        </ul>
      </>
    );
  }

  return (
    <>
      {renderChart()}
      {renderList()}
    </>
  );
}
