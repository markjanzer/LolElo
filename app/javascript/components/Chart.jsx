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
  ResponsiveContainer
} from "recharts";

// "Aug 18", "2022" => "August 18, 2022"
// "Start of Season Finals 2024" => "Start of Season Finals 2024"
function formatDateString(dateStr, year) {
  const date = new Date(`${dateStr} ${year}`);
  if (isNaN(date)) {
    return dateStr;
  }

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}


export const Chart = ({ data }) => {  
  const lineChartData = data.data;
  const teamData = data.teams;
  const matchData = data.matches;
  const year = data.year;

  const [selectedDate, setSeletedDate] = useState(
    matchData[matchData.length - 1].date
  );
  // Set default so chart doesn't rerender on first hover
  const [hoveredDate, setHoveredDate] = useState(
    matchData[matchData.length - 1].date
  );

  const [fontSize, setFontSize] = useState(14);
  const [aspectRatio, setAspectRatio] = useState(5 / 3); // Default aspect ratio
  const [chartLeft, setChartLeft] = useState(-12);

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      if (width < 640) {
        setFontSize(10);
        setAspectRatio(3 / 3);
        setChartLeft(-20);
      } else if (width < 1024) {
        setFontSize(12);
        setAspectRatio(4 / 3);
        setChartLeft(-12);
      } else {
        setFontSize(14);
        setAspectRatio(5 / 3);
        setChartLeft(-4);
      }
    };

    window.addEventListener('resize', handleResize);
    handleResize();

    return () => window.removeEventListener('resize', handleResize);
  }, []);

  function customToolTip(props) {
    return (
      <div>
        <div className="text-base sm:text-lg md:text-xl text-center">{props.label}</div>
        <ul className="my-2 mx-4">
          {matchData
            .filter((match) => match.date == props.label)
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
      <li key={match.id} className="flex m-2 bg-purple-popout rounded border border-green-accent">
        {renderMatchOpponent(match.opponent1.color, match.opponent1.acronym, match.opponent1_elo, match.opponent1_elo_change)}
        <div className="text-base lg:text-lg mt-4">{score}</div>
        {renderMatchOpponent(match.opponent2.color, match.opponent2.acronym, match.opponent2_elo, match.opponent2_elo_change)}
      </li>
    );
  }

  function renderMatchOpponent(color, acronym, elo, eloChange) {
    return (
      <div className="mx-3 my-2 flex flex-col items-center">
        <div
          className="text-base lg:text-lg "
          style={{ borderBottom: `2px solid ${color}` }}
        >
          {acronym}
        </div>
        <div className="flex flex-col items-end text-sm lg:text-md">
          <div>{elo}</div>
          {renderEloChange(eloChange)}
        </div>
      </div>
    )
  }

  function renderChart() {
    return (
      <ResponsiveContainer width="100%" aspect={aspectRatio}>
        <LineChart
          data={lineChartData}
          margin={{ left: chartLeft, right: 4 }}
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
          <XAxis 
            dataKey="name"
            tick={{ fontSize: fontSize}}
            tickFormatter={(value) => `${value}`}
          />
          <YAxis 
            type="number" 
            domain={["dataMin - 50", "dataMax + 50"]} 
            tick={{ fontSize: fontSize}}
            tickFormatter={(value) => `${value}`}
            padding={{ left: 0 }}
          />
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
      </ResponsiveContainer>
    );
  }

  function renderList() {
    const dateData = lineChartData.filter((d) => d.name === selectedDate)[0];
    const teamElos = teamData.reduce((result, team) => {
      const teamObj = {
        name: team.name,
        elo: dateData[team.acronym],
        color: team.color,
      };
      result.push(teamObj);
      return result;
    }, []);
    const sortedTeamElos = teamElos.sort(
      (a, b) => b.elo - a.elo
    );

    return (
      <div className="ml-1 md:ml-4 mr-2">
        <h2 
          className={"text-lg lg:text-xl mx-2 mb-2 mt-1 text-green-accent"}
        >{formatDateString(selectedDate, year)}</h2>
        <ul>
          {sortedTeamElos.map((team) => {
            return (
              <li 
                key={team.acronym}
                className="m-2 flex items-center"
              >
                <div
                  className="w-4 h-4 rounded-full mr-2"
                  style={{ backgroundColor: team.color }}
                />
                <span className="text-sm lg:text-base">{team.name}: {team.elo}</span>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }

  return (
    <div class="flex flex-col md:flex-row">
      {renderChart()}
      {renderList()}
    </div>
  );
}

// This is so dumb
// https://github.com/shakacode/react_on_rails/issues/1198#issuecomment-593486485
export default props => <Chart {...props} />;