import React, { useEffect, useState } from "react";

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

export const Chart = ({ data }) => {  
  const lineChartData = data.data;
  const teamData = data.teams;
  const matchData = data.matches;

  const [selectedDate, setSeletedDate] = useState(
    matchData[matchData.length - 1].date
  );
  const [hoveredDate, setHoveredDate] = useState(null);

  function customToolTip(props) {
    return (
      <div>
        <div className="text-2xl text-center">{props.label}</div>
        <ul className="my-2 mx-4">
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
    if (changeAmount < 0) {
      return <div className={"text-red-600"}>{changeAmount}</div>;
    } else {
      return <div className={"text-green-600"}>{`+ ${changeAmount}`}</div>;
    }
  }

  function renderMatch(match) {
    let score = `${match.opponent1_score} - ${match.opponent2_score}`;

    return (
      <li className="flex m-2 bg-purple-popout rounded border border-green-accent">
        <div className="mx-3 my-2 flex flex-col items-center">
          <div
            className="text-2xl"
            style={{ borderBottom: `2px solid ${match.opponent1.color}` }}
          >
            {match.opponent1.acronym}
          </div>
          <div className="flex flex-col items-end">
            <div>{match.opponent1_elo}</div>
            {renderEloChange(match.opponent1_elo_change)}
          </div>
        </div>
        <div className="text-lg mt-4">{score}</div>
        <div className="mx-3 my-2 flex flex-col items-center">
          <div
            className="text-2xl"
            style={{ borderBottom: `2px solid ${match.opponent2.color}` }}
          >
            {match.opponent2.acronym}
          </div>
          <div className="flex flex-col items-end">
            <div>{match.opponent2_elo}</div>
            {renderEloChange(match.opponent2_elo_change)}
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
        onMouseMove={(state) => {
          if (state.activeLabel) {
            setHoveredDate(state.activeLabel);
          }
        }}
      >
        <CartesianGrid />
        {hoveredDate && (
          <ReferenceLine
            x={hoveredDate}
            stroke="#aaa"
            strokeWidth={2}
          />
        )}
        {selectedDate && (
          <ReferenceLine
            x={selectedDate}
            stroke="#00D17A"
            strokeWidth={2}
          />
        )}
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
        name: team.name,
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
      <div className="my-1">
        <h2 className="text-2xl mx-2 my-4 text-green-accent">{selectedDate}</h2>
        <ul>
          {sortedFormattedDateData.map((datum) => {
            return (
              <li 
                key={datum.acronym}
                className="m-2"
              >
                {datum.name}: {datum.elo}
              </li>
            );
          })}
        </ul>
      </div>
    );
  }

  return (
    <>
      {renderChart()}
      {renderList()}
    </>
  );
}

// This is so dumb
// https://github.com/shakacode/react_on_rails/issues/1198#issuecomment-593486485
export default props => <Chart {...props} />;